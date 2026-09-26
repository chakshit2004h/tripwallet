import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TripEmptyState extends StatelessWidget {
  const TripEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.paper,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.ink, size: 24),
            ),
            const SizedBox(height: 18),
            Text('No trips yet', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Create one and share the link — everyone joins in seconds, no account needed.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () => context.push('/create-trip'),
                child: const Text('Create a trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
