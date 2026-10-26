import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_router_refresh.dart';
import '../auth/supabase_auth_service.dart';
import '../../features/profile/presentation/privacy_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
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
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/expenses/presentation/manual_expense_screen.dart';
import '../../features/expenses/presentation/expense_detail_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/presentation/main_dashboard_screen.dart';

CustomTransitionPage<void> _slideRightToLeft(LocalKey key, Widget child) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final refresh = AuthRouterRefresh(client?.auth.onAuthStateChange);
  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.uri.path;
      if (state.uri.host == 'join' || path == '/join') {
        return Uri(
          path: '/join-trip',
          queryParameters: {'code': state.uri.queryParameters['code'] ?? ''},
        ).toString();
      }
      if (refresh.recovering && path != '/reset-password') {
        return '/reset-password';
      }
      final public = [
        '/',
        '/welcome',
        '/login',
        '/register',
        '/verify-email',
        '/privacy',
        '/auth-callback',
      ].contains(path);
      if (client?.auth.currentSession == null && !public) {
        return Uri(
          path: '/login',
          queryParameters: {'next': state.uri.toString()},
        ).toString();
      }
      if (client?.auth.currentSession != null &&
          [
            '/',
            '/welcome',
            '/login',
            '/register',
            '/verify-email',
            '/auth-callback',
          ].contains(path)) {
        final next = state.uri.queryParameters['next'];
        return next != null && next.startsWith('/') && !next.startsWith('//')
            ? next
            : '/trips';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('TripWallet')),
      body: Center(
        child: TextButton(
          onPressed: () => context.go('/'),
          child: const Text('Return home'),
        ),
      ),
    ),
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => VerifyEmailScreen(
          email: state.uri.queryParameters['email'] ?? '',
          next: state.uri.queryParameters['next'] ?? '/trips',
          codeJustSent: state.uri.queryParameters['sent'] != 'false',
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _slideRightToLeft(
          state.pageKey,
          LoginScreen(initialEmail: state.uri.queryParameters['email'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            _slideRightToLeft(state.pageKey, const RegisterScreen()),
      ),
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (BuildContext context, GoRouterState state) =>
            const WelcomeScreen(),
      ),
      GoRoute(
        path: '/landing',
        builder: (BuildContext context, GoRouterState state) =>
            const LandingScreen(),
      ),
      GoRoute(
        path: '/create-trip',
        builder: (BuildContext context, GoRouterState state) =>
            const CreateTripScreen(),
      ),
      GoRoute(
        path: '/invite',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.uri.queryParameters['tripId'] ?? '';
          final inviteCode = state.uri.queryParameters['inviteCode'] ?? '';
          return InviteShareScreen(tripId: tripId, inviteCode: inviteCode);
        },
      ),
      GoRoute(
        path: '/join-trip',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.uri.queryParameters['tripId'] ?? '';
          return JoinTripScreen(
            tripId: tripId,
            initialCode: state.uri.queryParameters['code'],
          );
        },
      ),
      GoRoute(
        path: '/trips',
        builder: (BuildContext context, GoRouterState state) =>
            const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/alerts',
        builder: (BuildContext context, GoRouterState state) =>
            const AlertsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) =>
            const ProfileScreen(),
      ),
      GoRoute(
        path: '/expense/manual',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.uri.queryParameters['tripId'] ?? '';
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
          final tripId = state.pathParameters['id'] ?? '';
          return TripDashboardScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trip/:id/settings',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.pathParameters['id'] ?? '';
          return TripSettingsScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trip/:id/members',
        builder: (BuildContext context, GoRouterState state) {
          final tripId = state.pathParameters['id'] ?? '';
          return MembersListScreen(tripId: tripId);
        },
      ),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacyScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (_, __) => const ResetPasswordScreen(),
      ),
      GoRoute(path: '/auth-callback', builder: (_, __) => const LoginScreen()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
