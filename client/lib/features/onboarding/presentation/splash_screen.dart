import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/db/database_seeder.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Seed initial demo data matching prototype if empty
    final db = ref.read(databaseProvider);
    await DatabaseSeeder.seedIfEmpty(db);

    _timer = Timer(const Duration(milliseconds: 1400), () {
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
            // App Mark matching Step 1
            SizedBox(
              width: 56,
              height: 56,
              child: CustomPaint(
                painter: _SplashMarkPainter(),
              ),
            ),
            const SizedBox(height: 14),
            // Wordmark
            RichText(
              text: TextSpan(
                style: AppTypography.display.copyWith(fontSize: 22, color: AppColors.cream),
                children: const [
                  TextSpan(text: 'Trip'),
                  TextSpan(
                    text: 'Wallet',
                    style: TextStyle(color: AppColors.coral),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(active: true),
                const SizedBox(width: 6),
                _buildDot(active: false),
                const SizedBox(width: 6),
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
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppColors.coral : const Color(0x47F4EFE4),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SplashMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.cream
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 72.0;

    // Outer wallet lines
    canvas.drawLine(Offset(20 * scale, 27 * scale), Offset(52 * scale, 27 * scale), linePaint);
    canvas.drawLine(Offset(20 * scale, 45 * scale), Offset(52 * scale, 45 * scale), linePaint);

    final path = Path()
      ..moveTo(20 * scale, 27 * scale)
      ..lineTo(20 * scale, 45 * scale)
      ..arcToPoint(Offset(24 * scale, 49 * scale), radius: Radius.circular(4 * scale))
      ..lineTo(48 * scale, 49 * scale)
      ..arcToPoint(Offset(52 * scale, 45 * scale), radius: Radius.circular(4 * scale))
      ..lineTo(52 * scale, 27 * scale);
    canvas.drawPath(path, linePaint);

    // Coral circle
    final circlePaint = Paint()
      ..color = AppColors.coral
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(52 * scale, 52 * scale), 12 * scale, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
