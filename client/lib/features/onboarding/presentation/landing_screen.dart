import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                'Where to?',
                style: AppTypography.display.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 20),

              // Button 1: Create a trip (primary)
              ElevatedButton.icon(
                onPressed: () => context.push('/create-trip'),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Create a trip'),
              ),
              const SizedBox(height: 12),

              // Button 2: Join a trip (ghost)
              OutlinedButton.icon(
                onPressed: () => context.push('/join-trip'),
                icon: const Icon(Icons.qr_code_rounded, size: 20),
                label: const Text('Join a trip'),
              ),

              const SizedBox(height: 24),
              // Quick link to browse all your trips
              Center(
                child: TextButton(
                  onPressed: () => context.push('/trips'),
                  child: Text('View Your Trips →', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
