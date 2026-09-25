import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Mark
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.lineHeavy, width: 1.5),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.coral,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            // Wordmark
            RichText(
              text: TextSpan(
                style: AppTypography.display.copyWith(fontSize: 26),
                children: const [
                  TextSpan(text: 'Trip'),
                  TextSpan(
                    text: 'Wallet',
                    style: TextStyle(color: AppColors.coral),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(active: true),
                const SizedBox(width: 8),
                _buildDot(active: false),
                const SizedBox(width: 8),
                _buildDot(active: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required bool active}) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? AppColors.coral : AppColors.lineHeavy,
        shape: BoxShape.circle,
      ),
    );
  }
}
