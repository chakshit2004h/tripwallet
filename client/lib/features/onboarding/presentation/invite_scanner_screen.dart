import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../domain/invite_code.dart';

class InviteScannerScreen extends StatefulWidget {
  const InviteScannerScreen({super.key});

  @override
  State<InviteScannerScreen> createState() => _InviteScannerScreenState();
}

class _InviteScannerScreenState extends State<InviteScannerScreen> {
  bool _completed = false;
  String? _error;
  int _cameraAttempt = 0;

  void _detect(BarcodeCapture capture) {
    if (_completed || !mounted || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    for (final barcode in capture.barcodes) {
      if (barcode.format != BarcodeFormat.qrCode) continue;
      final code = inviteCodeFromInput(barcode.rawValue ?? '', scanned: true);
      if (code != null) {
        _completed = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
    if (_error == null) {
      setState(
        () => _error =
            'This isn’t a TripWallet invite. Scan the QR code on your friend’s Invite friends screen.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Scan trip QR code')),
    body: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Point your camera at a TripWallet invite QR code to join the trip.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: MobileScanner(
                  key: ValueKey(_cameraAttempt),
                  // With no external controller, the widget owns camera lifecycle and disposal.
                  onDetect: _detect,
                  errorBuilder: (context, error) => ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.no_photography_outlined, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              error.errorCode ==
                                      MobileScannerErrorCode.permissionDenied
                                  ? 'Camera access is off. Allow TripWallet to use the camera in your phone settings, then try again.'
                                  : 'Could not start the camera. Try again or enter the invite code instead.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () => setState(() => _cameraAttempt++),
                              child: const Text('Try camera again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.keyboard_outlined),
              label: const Text('Enter code instead'),
            ),
          ),
        ],
      ),
    ),
  );
}
