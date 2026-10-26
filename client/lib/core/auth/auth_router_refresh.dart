import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Refresh routing on auth events without letting background refresh failures
/// escape as unhandled stream errors. A network failure does not sign out users.
class AuthRouterRefresh extends ChangeNotifier {
  StreamSubscription<AuthState>? _subscription;
  bool recovering = false;

  AuthRouterRefresh(Stream<AuthState>? events) {
    _subscription = events?.listen(
      (event) {
        if (event.event == AuthChangeEvent.passwordRecovery) recovering = true;
        if (event.event == AuthChangeEvent.signedOut ||
            event.event == AuthChangeEvent.userUpdated) {
          recovering = false;
        }
        notifyListeners();
      },
      onError: (Object error, StackTrace stack) {
        // The SDK retains the session on retryable failures. Subsequent auth
        // events still arrive; RPC callers report connection errors in their UI.
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
