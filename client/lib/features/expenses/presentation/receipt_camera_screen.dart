import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/receipt_text_recognizer.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/data/app_error.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../domain/receipt_parser.dart';
import 'line_item_review_screen.dart';

class ReceiptCameraScreen extends ConsumerStatefulWidget {
  final String tripId;
  const ReceiptCameraScreen({super.key, required this.tripId});
  @override
  ConsumerState<ReceiptCameraScreen> createState() =>
      _ReceiptCameraScreenState();
}

class _ReceiptCameraScreenState extends ConsumerState<ReceiptCameraScreen> {
  bool _busy = false;
  String? _error;
  final _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) _recover();
  }

  Future<void> _recover() async {
    try {
      final response = await _picker.retrieveLostData();
      if (!mounted) return;
      if (response.files?.isNotEmpty == true) {
        await _recognize(response.files!.first);
      } else if (response.exception != null) {
        setState(
          () => _error =
              'The captured photo could not be recovered. Please take it again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'The captured photo could not be recovered. Please take it again.',
        );
      }
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 2400,
        imageQuality: 95,
      );
      if (file != null && mounted) await _recognize(file);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not open the camera or photo picker. Check camera access in your device settings.',
        );
      }
    }
  }

  Future<void> _recognize(XFile file) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final recognizer = ReceiptTextRecognizer();
    var loadingTrip = false;
    try {
      final text = await recognizer.recognize(file.path);
      if (!mounted) return;
      if (text.trim().isEmpty) {
        setState(
          () => _error =
              'No text was detected. Keep the receipt flat, fill the frame, and avoid blur or glare. The scanner currently reads Latin-script text, such as English.',
        );
        return;
      }
      loadingTrip = true;
      final data = await ref.read(tripRepositoryProvider).read();
      final trip = data.trips.firstWhere((t) => t.id == widget.tripId);
      final member = data.myMemberId(
        trip.id,
        ref.read(accountIdProvider) ?? '',
      );
      if (member == null) throw StateError('Trip members are not loaded');
      loadingTrip = false;
      final receipt = parseReceiptText(
        text,
        tripId: trip.id,
        currency: trip.baseCurrency,
        payerMemberId: member,
      );
      if (!mounted) return;
      if (receipt.items.isEmpty) {
        setState(
          () => _error =
              'Text was detected, but no item prices could be matched. Include both the item names and the price column, or enter this bill manually.',
        );
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LineItemReviewScreen(receipt: receipt),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = loadingTrip
              ? appError(e)
              : 'Could not process this photo. Try another photo or enter the expense manually.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supported = Platform.isAndroid || Platform.isIOS;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a receipt')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const EmptyState(
              icon: Icons.document_scanner_outlined,
              title: 'Every dish. Every share.',
              message:
                  'Take a clear photo of the whole receipt. You’ll review the items and prices before splitting.',
            ),
            if (_busy) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              const Text(
                'Reading your receipt on this device…',
                textAlign: TextAlign.center,
              ),
            ] else if (supported) ...[
              ElevatedButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take a photo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose a photo'),
              ),
            ] else
              Text(
                'Receipt scanning is available on Android and iOS. Use manual entry on this device.',
                style: AppTypography.bodyLarge,
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Photos are processed on your device. Check totals against the original bill, especially discounts and service charges.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
