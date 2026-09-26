import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/landing_screen.dart';
import '../../features/onboarding/presentation/create_trip_screen.dart';
import '../../features/onboarding/presentation/invite_share_screen.dart';
import '../../features/onboarding/presentation/join_trip_screen.dart';
import '../../features/trip_dashboard/presentation/trip_dashboard_screen.dart';
import '../../features/trip_dashboard/presentation/trip_settings_screen.dart';
import '../../features/trip_dashboard/presentation/members_list_screen.dart';
import '../../features/paywall/presentation/pass_active_screen.dart';
import '../../features/trips/presentation/your_trips_screen.dart';
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/expenses/presentation/manual_expense_screen.dart';
import '../../features/expenses/presentation/expense_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (BuildContext context, GoRouterState state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/landing',
      builder: (BuildContext context, GoRouterState state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/create-trip',
      builder: (BuildContext context, GoRouterState state) => const CreateTripScreen(),
    ),
    GoRoute(
      path: '/invite',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.uri.queryParameters['tripId'] ?? 'demo-trip';
        final inviteCode = state.uri.queryParameters['inviteCode'] ?? '9f2k4';
        return InviteShareScreen(tripId: tripId, inviteCode: inviteCode);
      },
    ),
    GoRoute(
      path: '/join-trip',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.uri.queryParameters['tripId'] ?? 'demo-trip';
        return JoinTripScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trips',
      builder: (BuildContext context, GoRouterState state) => const YourTripsScreen(),
    ),
    GoRoute(
      path: '/alerts',
      builder: (BuildContext context, GoRouterState state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/expense/manual',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.uri.queryParameters['tripId'] ?? 'demo-trip';
        return ManualExpenseScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/expense/:id',
      builder: (BuildContext context, GoRouterState state) {
        final expenseId = state.pathParameters['id'] ?? '';
        return ExpenseDetailScreen(expenseId: expenseId);
      },
    ),
    GoRoute(
      path: '/trip/:id',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.pathParameters['id'] ?? 'demo-trip';
        return TripDashboardScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trip/:id/settings',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.pathParameters['id'] ?? 'demo-trip';
        return TripSettingsScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trip/:id/members',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.pathParameters['id'] ?? 'demo-trip';
        return MembersListScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trip/:id/pass-active',
      builder: (BuildContext context, GoRouterState state) {
        return const PassActiveScreen(tripName: 'Goa weekend');
      },
    ),
  ],
);
