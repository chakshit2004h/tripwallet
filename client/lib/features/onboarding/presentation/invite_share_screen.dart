import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';

class InviteShareScreen extends StatelessWidget {
  final String tripId;
  final String inviteCode;
  const InviteShareScreen({
    super.key,
    required this.tripId,
    required this.inviteCode,
  });
  @override
  Widget build(BuildContext context) {
    final link = 'tripwallet://join?code=$inviteCode';
    return Scaffold(
      appBar: AppBar(title: const Text('Invite friends')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Better with your crew.',
              style: AppTypography.display,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Friends can open Join a trip in TripWallet and scan this QR code or enter the invite code.',
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.line),
                ),
                child: QrImageView(
                  data: link,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SelectableText(
              inviteCode,
              style: AppTypography.display.copyWith(letterSpacing: 4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: inviteCode));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invite code copied')),
                  );
                }
              },
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy invite code'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await SharePlus.instance.share(
                    ShareParams(
                      text:
                          'Join my trip on TripWallet! Open the app, choose Join a trip, and enter $inviteCode.\n$link',
                    ),
                  );
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Sharing is unavailable. Copy the invite code instead.',
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.ios_share),
              label: const Text('Share invite'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.go('/trip/$tripId'),
              child: const Text('Open trip dashboard →'),
            ),
          ],
        ),
      ),
    );
  }
}
