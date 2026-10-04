import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/auth/supabase_auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  // Staggered Animations
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;

  late final Animation<double> _quoteFade;
  late final Animation<Offset> _quoteSlide;

  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // 1. Logo & App Title: 0.0 -> 0.45
    _logoFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    ));

    // 2. Quote below title: 0.35 -> 0.75
    _quoteFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );
    _quoteSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
    ));

    // 3. Get Started Button below quote: 0.65 -> 1.0
    _buttonFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
    ));

    _animController.forward();
    _checkAuthAndAutoNavigate();
  }

  Future<void> _checkAuthAndAutoNavigate() async {
    // Give time to showcase the splash branding
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final auth = ref.read(supabaseAuthServiceProvider);
    if (auth.isAuthenticated) {
      context.go('/trips');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // 1. Animated Brand Logo & Title
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral.withValues(alpha: 0.4),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          style: AppTypography.display.copyWith(
                            fontSize: 36,
                            letterSpacing: -0.5,
                            color: AppColors.cream,
                          ),
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
                ),
              ),

              const SizedBox(height: 18),

              // 2. Animated Quote directly below Title
              SlideTransition(
                position: _quoteSlide,
                child: FadeTransition(
                  opacity: _quoteFade,
                  child: Column(
                    children: [
                      Text(
                        '“Collect memories, not receipts.”',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.cream.withValues(alpha: 0.92),
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Travel together. Split effortlessly.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 4),

              // 3. Get Started Button below quote (slides in and transitions right-to-left to auth)
              SlideTransition(
                position: _buttonSlide,
                child: FadeTransition(
                  opacity: _buttonFade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Primary "Get Started" CTA
                      ElevatedButton(
                        onPressed: () => context.push('/register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.coral.withValues(alpha: 0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: AppTypography.button.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Secondary Sign In link
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/login'),
                          child: RichText(
                            text: TextSpan(
                              style: AppTypography.bodySmall.copyWith(color: AppColors.cream),
                              children: const [
                                TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Sign in',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.coral,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Offline demo link
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/trips'),
                          child: Text(
                            'Continue as Guest / Offline',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
