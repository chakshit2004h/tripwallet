import 'dart:convert';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripwallet_client/core/auth/supabase_auth_service.dart';
import 'package:tripwallet_client/core/theme/app_theme.dart';
import 'package:tripwallet_client/features/auth/presentation/auth_form_screen.dart';
import 'package:tripwallet_client/features/auth/presentation/auth_notice.dart';
import 'package:tripwallet_client/features/auth/presentation/login_screen.dart';
import 'package:tripwallet_client/features/auth/presentation/verify_email_screen.dart';

Map<String, dynamic> sessionJson() => {
  'access_token': 'test-access-token',
  'refresh_token': 'test-refresh-token',
  'token_type': 'bearer',
  'expires_in': 3600,
  'user': {
    'id': 'user-id',
    'aud': 'authenticated',
    'email': 'traveler@example.com',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{},
    'created_at': '2026-01-01T00:00:00Z',
    'email_confirmed_at': '2026-01-01T00:01:00Z',
  },
};

class FakeSignupAuth extends SupabaseAuthService {
  int sends = 0;
  int verifications = 0;
  bool reject = true;
  bool alreadyRegistered = false;
  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    String? paymentVpa,
  }) async {
    if (alreadyRegistered) {
      throw const AuthException(
        'User already registered',
        code: 'user_already_exists',
      );
    }
    return AuthResponse();
  }

  @override
  Future<AuthResponse> verifySignupCode({
    required String email,
    required String code,
  }) async {
    verifications++;
    if (reject) {
      throw const AuthException(
        'Token has expired or is invalid',
        code: 'otp_expired',
      );
    }
    return AuthResponse.fromJson(sessionJson());
  }

  @override
  Future<void> resendSignupCode(String email) async {
    sends++;
  }
}

void main() {
  test(
    'verify sends email OTP to Supabase and persists the signed-in session',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.supabase.co',
        'public-key',
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.implicit,
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode(sessionJson()),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final service = SupabaseAuthService(client: client);
      final response = await service.verifySignupCode(
        email: ' traveler@example.com ',
        code: ' 123456 ',
      );
      expect(requests.single.url.path, '/auth/v1/verify');
      final body = jsonDecode(requests.single.body) as Map;
      expect(body['email'], 'traveler@example.com');
      expect(body['token'], '123456');
      expect(body['type'], 'email');
      expect(response.session, isNotNull);
      expect(client.auth.currentUser?.id, 'user-id');
      await client.dispose();
    },
  );

  test(
    'resend requests a signup confirmation, not a passwordless login',
    () async {
      late http.Request request;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'public-key',
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.implicit,
        ),
        httpClient: MockClient((r) async {
          request = r;
          return http.Response('{}', 200);
        }),
      );
      await SupabaseAuthService(
        client: client,
      ).resendSignupCode('traveler@example.com');
      expect(request.url.path, '/auth/v1/resend');
      expect(jsonDecode(request.body)['type'], 'signup');
      await client.dispose();
    },
  );

  test(
    'existing confirmed email does not claim a verification code was sent',
    () async {
      final client = SupabaseClient(
        'https://example.supabase.co',
        'public-key',
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.implicit,
        ),
        httpClient: MockClient((request) async {
          expect(request.url.path, '/auth/v1/signup');
          final user = Map<String, dynamic>.from(sessionJson()['user'] as Map);
          user.remove('email_confirmed_at');
          user['identities'] = <dynamic>[];
          return http.Response(jsonEncode(user), 200);
        }),
      );
      addTearDown(client.dispose);
      await expectLater(
        SupabaseAuthService(client: client).signUp(
          email: 'traveler@example.com',
          password: 'test-password',
          displayName: 'Traveler',
        ),
        throwsA(
          isA<AuthException>()
              .having((error) => error.code, 'code', 'user_already_exists')
              .having(
                (error) => error.message,
                'message',
                contains('Sign in instead'),
              ),
        ),
      );
    },
  );

  testWidgets(
    'existing email offers sign in with email and destination preserved',
    (tester) async {
      final auth = FakeSignupAuth()..alreadyRegistered = true;
      final router = GoRouter(
        initialLocation: '/register?next=%2Fjoin-trip',
        routes: [
          GoRoute(
            path: '/register',
            builder: (_, __) => const AuthFormScreen(register: true),
          ),
          GoRoute(
            path: '/login',
            builder: (_, state) => LoginScreen(
              initialEmail: state.uri.queryParameters['email'] ?? '',
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [supabaseAuthServiceProvider.overrideWithValue(auth)],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Traveler');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'traveler@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'test-password');
      await tester.scrollUntilVisible(
        find.text('Create account'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AuthNotice>(find.byType(AuthNotice)).isError,
        isTrue,
      );
      expect(
        find.text('Email already in use. Please sign in.'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Sign in'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/login');
      expect(
        router.routeInformationProvider.value.uri.queryParameters['next'],
        '/join-trip',
      );
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(0))
            .controller
            ?.text,
        'traveler@example.com',
      );
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller
            ?.text,
        isEmpty,
      );
    },
  );

  testWidgets(
    'invalid codes stay on verification in red; correct code opens destination',
    (tester) async {
      final auth = FakeSignupAuth();
      final router = GoRouter(
        initialLocation: '/verify',
        routes: [
          GoRoute(
            path: '/verify',
            builder: (_, __) => const VerifyEmailScreen(
              email: 'traveler@example.com',
              next: '/join-trip',
            ),
          ),
          GoRoute(
            path: '/join-trip',
            builder: (_, __) => const Scaffold(body: Text('Join destination')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseAuthServiceProvider.overrideWithValue(auth),
            emailSignupOtpEnabledProvider.overrideWithValue(true),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.tap(find.text('Verify & continue'));
      await tester.pump();
      expect(auth.verifications, 0);
      expect(
        find.text('Enter the 6-digit code from your email.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify & continue'));
      await tester.pumpAndSettle();
      expect(auth.verifications, 1);
      final notice = tester.widget<AuthNotice>(find.byType(AuthNotice));
      expect(notice.isError, isTrue);
      expect(notice.message, contains('incorrect or has expired'));
      expect(
        tester.widget<Text>(find.text(notice.message)).style?.color,
        AppTheme.lightTheme.colorScheme.error,
      );
      auth.reject = false;
      await tester.ensureVisible(find.text('Verify & continue'));
      await tester.tap(find.text('Verify & continue'));
      await tester.pumpAndSettle();
      expect(find.text('Join destination'), findsOneWidget);
    },
  );

  testWidgets('resend waits 60 seconds, sends once and restarts cooldown', (
    tester,
  ) async {
    var now = DateTime(2026);
    await withClock(Clock(() => now), () async {
      final auth = FakeSignupAuth();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseAuthServiceProvider.overrideWithValue(auth),
            emailSignupOtpEnabledProvider.overrideWithValue(true),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const VerifyEmailScreen(email: 'traveler@example.com'),
          ),
        ),
      );
      final button = find.widgetWithText(TextButton, 'Resend code in 60s');
      expect(tester.widget<TextButton>(button).onPressed, isNull);
      now = now.add(const Duration(seconds: 60));
      await tester.pump(const Duration(seconds: 60));
      await tester.ensureVisible(find.text('Resend code'));
      await tester.tap(find.text('Resend code'));
      await tester.pumpAndSettle();
      expect(auth.sends, 1);
      expect(find.text('Resend code in 60s'), findsOneWidget);
      expect(
        tester.widget<AuthNotice>(find.byType(AuthNotice)).isError,
        isFalse,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets(
    'signup opens verification and change email preserves the entered form',
    (tester) async {
      final auth = FakeSignupAuth();
      final router = GoRouter(
        initialLocation: '/register?next=%2Fjoin-trip',
        routes: [
          GoRoute(
            path: '/register',
            builder: (_, __) => const AuthFormScreen(register: true),
          ),
          GoRoute(
            path: '/verify-email',
            builder: (_, state) => VerifyEmailScreen(
              email: state.uri.queryParameters['email']!,
              next: state.uri.queryParameters['next']!,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseAuthServiceProvider.overrideWithValue(auth),
            emailSignupOtpEnabledProvider.overrideWithValue(true),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'Traveler');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'traveler@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'test-password');
      await tester.scrollUntilVisible(
        find.text('Create account'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Check your inbox'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.queryParameters['next'],
        '/join-trip',
      );
      await tester.ensureVisible(
        find.widgetWithText(TextButton, 'Change email'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change email'));
      await tester.pumpAndSettle();
      expect(find.byType(AuthFormScreen), findsOneWidget);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(find.text('traveler@example.com'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
