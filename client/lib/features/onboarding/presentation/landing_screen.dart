import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Icon Cluster
              Row(
                children: [
                  _buildIconBadge(Icons.receipt_long_rounded),
                  const SizedBox(width: 10),
                  _buildIconBadge(Icons.bolt_rounded),
                  const SizedBox(width: 10),
                  _buildIconBadge(Icons.signal_cellular_connected_no_internet_4_bar_rounded),
                ],
              ),
              const SizedBox(height: 24),
              // Headline
              Text(
                'Group expenses,\nsettled in one tap.',
                style: AppTypography.display.copyWith(fontSize: 30, height: 1.2),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'Split dishes by scanning receipts, track group balances offline, and settle instantly with native payment apps. No account required.',
                style: AppTypography.bodyLarge,
              ),
              const Spacer(),
              // Primary CTA: Create a trip
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/create-trip');
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Create a trip'),
              ),
              const SizedBox(height: 12),
              // Secondary CTA: Join a trip
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/join-trip');
                },
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                label: const Text('Join via invite link / QR'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line, width: 1.2),
      ),
      child: Icon(icon, color: AppColors.cream, size: 22),
    );
  }
}
