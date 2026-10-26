import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripwallet_client/core/auth/auth_router_refresh.dart';
import 'package:tripwallet_client/core/data/app_error.dart';

void main() {
  test(
    'background refresh failure is handled and later auth events still arrive',
    () async {
      final events = StreamController<AuthState>();
      final refresh = AuthRouterRefresh(events.stream);
      var notifications = 0;
      refresh.addListener(() => notifications++);
      events.addError(
        AuthRetryableFetchException(message: 'Failed host lookup'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 1);
      expect(refresh.recovering, isFalse);
      events.add(AuthState(AuthChangeEvent.passwordRecovery, null));
      await Future<void>.delayed(Duration.zero);
      expect(refresh.recovering, isTrue);
      events.addError(
        AuthRetryableFetchException(message: 'Failed host lookup'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(refresh.recovering, isTrue);
      events.add(AuthState(AuthChangeEvent.signedOut, null));
      await Future<void>.delayed(Duration.zero);
      expect(refresh.recovering, isFalse);
      expect(notifications, 4);
      refresh.dispose();
      await events.close();
    },
  );
  test(
    'connection errors explain retry without exposing raw transport details',
    () {
      for (final error in [
        AuthRetryableFetchException(
          message: 'Failed host lookup: private-host',
        ),
        const SocketException('Failed host lookup'),
        ClientException('Failed host lookup'),
        TimeoutException('timeout'),
      ]) {
        expect(appError(error), contains('Wi-Fi and mobile data'));
        expect(appError(error), isNot(contains('private-host')));
      }
      expect(
        appError(const AuthException('Invalid login credentials')),
        'Invalid login credentials',
      );
    },
  );
}
