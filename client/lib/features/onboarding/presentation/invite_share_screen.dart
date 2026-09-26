import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class InviteShareScreen extends StatelessWidget {
  final String tripId;
  final String inviteCode;

  const InviteShareScreen({
    super.key,
    this.tripId = 'demo-trip',
    this.inviteCode = '9f2k4',
  });

  @override
  Widget build(BuildContext context) {
    final inviteUrl = 'tripwallet.app/j/$inviteCode';

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Invite', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Invite your crew',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Anyone with this link joins instantly, no account needed.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 24),

              // QR Card matching Step 5 (150x150)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2_rounded, size: 88, color: AppColors.inkText),
                ),
              ),
              const SizedBox(height: 20),

              // Link row
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'https://$inviteUrl'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied!')),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          inviteUrl,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.inkSoft),
                        ),
                      ),
                      const Icon(Icons.copy_rounded, size: 16, color: AppColors.inkSoft),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Primary Share Button
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Shared to WhatsApp: https://$inviteUrl')),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Share to WhatsApp'),
              ),
              const SizedBox(height: 10),

              // Open Trip Dashboard button
              OutlinedButton(
                onPressed: () => context.go('/trip/$tripId'),
                child: const Text('Open trip dashboard'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
