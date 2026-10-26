import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/launch_splash.dart';
import 'core/router/app_router.dart';

class TripWalletApp extends ConsumerWidget {
  const TripWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TripWallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) =>
          LaunchSplash(child: child ?? const SizedBox.shrink()),
    );
  }
}
