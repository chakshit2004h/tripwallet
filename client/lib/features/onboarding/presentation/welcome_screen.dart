import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // 3 Icons matching prototype Step 2
              Row(
                children: [
                  _buildIconBadge(Icons.camera_alt_outlined),
                  const SizedBox(width: 10),
                  _buildIconBadge(Icons.account_balance_wallet_outlined),
                  const SizedBox(width: 10),
                  _buildIconBadge(Icons.map_outlined),
                ],
              ),
              const SizedBox(height: 28),

              // Title matching Step 2
              Text(
                'Scan the bill, tap your dish, settle in one tap',
                style: AppTypography.display.copyWith(
                  fontSize: 24,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),

              // Subtitle matching Step 2
              Text(
                'Split trip expenses by line item and pay each other instantly through GPay, PhonePe, Stripe or Apple Cash.',
                style: AppTypography.bodyLarge,
              ),

              const Spacer(),

              // Primary CTA
              ElevatedButton(
                onPressed: () => context.go('/landing'),
                child: const Text('Get started'),
              ),
              const SizedBox(height: 12),
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
      ),
      child: Icon(icon, color: AppColors.ink, size: 20),
    );
  }
}
