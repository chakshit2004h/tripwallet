import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/landing_screen.dart';
import '../../features/trip_dashboard/presentation/trip_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/landing',
      builder: (BuildContext context, GoRouterState state) {
        return const LandingScreen();
      },
    ),
    GoRoute(
      path: '/trip/:id',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.pathParameters['id'] ?? '';
        return TripDashboardScreen(tripId: tripId);
      },
    ),
  ],
);
