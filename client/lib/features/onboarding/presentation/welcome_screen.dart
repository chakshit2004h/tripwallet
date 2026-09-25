import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Brand mark
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.lineHeavy),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.coral,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.display.copyWith(fontSize: 20),
                      children: const [
                        TextSpan(text: 'Trip'),
                        TextSpan(
                          text: 'Wallet',
                          style: TextStyle(color: AppColors.coral),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Feature Icon Badges
              Row(
                children: [
                  _buildIconBadge(Icons.camera_alt_rounded, 'Scan', AppColors.coral),
                  const SizedBox(width: 12),
                  _buildIconBadge(Icons.touch_app_rounded, 'Claim', AppColors.green),
                  const SizedBox(width: 12),
                  _buildIconBadge(Icons.bolt_rounded, 'Settle', AppColors.amber),
                ],
              ),
              const SizedBox(height: 28),

              // Headline
              Text(
                'Scan the bill,\ntap your dish,\nsettle in one tap.',
                style: AppTypography.display.copyWith(
                  fontSize: 32,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Split trip expenses by line item with OCR receipt scanning, keep balances sync\'d offline with CRDTs, and settle instantly with UPI, Revolut, or Apple Cash.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),

              // Value props
              _buildValueProp(Icons.wifi_off_rounded, '100% Offline-first with auto-sync'),
              const SizedBox(height: 8),
              _buildValueProp(Icons.no_accounts_rounded, 'Accountless guest identity — zero sign-up friction'),
              const SizedBox(height: 8),
              _buildValueProp(Icons.receipt_long_rounded, 'Itemized receipt proration down to exact cents'),

              const Spacer(),

              // Primary CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go('/landing'),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueProp(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.coral),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption.copyWith(color: AppColors.cream),
          ),
        ),
      ],
    );
  }
}
