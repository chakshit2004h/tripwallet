import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class TripWalletApp extends StatelessWidget {
  const TripWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TripWallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
