import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../../../core/widgets/journey_art.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(width: 12),
                Text('TripWallet', style: AppTypography.titleLarge),
              ],
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: const JourneyArt(height: 220),
            ),
            const SizedBox(height: 30),
            Text(
              'More memories.\nLess money talk.',
              style: AppTypography.display.copyWith(fontSize: 38, height: 1.12),
            ),
            const SizedBox(height: 14),
            Text(
              'One place for your crew, shared expenses, and everything you’ve got planned.',
              style: AppTypography.bodyLarge.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _feature(Icons.receipt_long_outlined, 'Split fairly'),
                _feature(Icons.document_scanner_outlined, 'Scan bills'),
                _feature(Icons.map_outlined, 'Plan together'),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go('/register'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Get started'),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already a member? Sign in'),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _feature(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.ink),
        const SizedBox(width: 7),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.ink),
        ),
      ],
    ),
  );
}
