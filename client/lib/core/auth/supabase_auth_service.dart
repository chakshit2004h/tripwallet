import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthService(client: client);
});

final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return const Stream.empty();
  }
  final authService = ref.watch(supabaseAuthServiceProvider);
  return authService.authStateChanges;
});

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? paymentVpa;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.paymentVpa,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      displayName: map['display_name'] as String? ?? 'Traveler',
      avatarUrl: map['avatar_url'] as String?,
      paymentVpa: map['payment_vpa'] as String?,
    );
  }
}

class SupabaseAuthService {
  final SupabaseClient? client;

  SupabaseAuthService({this.client});

  Stream<AuthState> get authStateChanges =>
      client?.auth.onAuthStateChange ?? const Stream.empty();

  User? get currentUser => client?.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  String? get currentUserId => currentUser?.id;

  String get currentDisplayName =>
      currentUser?.userMetadata?['display_name'] as String? ??
      currentUser?.email?.split('@').first ??
      'You';

  String? get currentPaymentVpa =>
      currentUser?.userMetadata?['payment_vpa'] as String?;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    String? paymentVpa,
  }) async {
    final c = client;
    if (c == null) throw Exception('Supabase client not initialized');

    final response = await c.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': displayName,
        if (paymentVpa != null && paymentVpa.isNotEmpty) 'payment_vpa': paymentVpa,
      },
    );

    // If user created, ensure profiles table has display name and VPA
    if (response.user != null) {
      try {
        await c.from('profiles').upsert({
          'id': response.user!.id,
          'email': email,
          'display_name': displayName,
          if (paymentVpa != null && paymentVpa.isNotEmpty) 'payment_vpa': paymentVpa,
        });
      } catch (_) {
        // Handled by SQL trigger if available
      }
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final c = client;
    if (c == null) throw Exception('Supabase client not initialized');

    return await c.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client?.auth.signOut();
  }

  Future<UserProfile?> fetchUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final c = client;
    if (c != null) {
      try {
        final data = await c
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          return UserProfile.fromMap(data);
        }
      } catch (_) {}
    }

    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      displayName: currentDisplayName,
      paymentVpa: currentPaymentVpa,
    );
  }

  Future<void> updateProfile({
    String? displayName,
    String? paymentVpa,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    final c = client;
    if (user == null || c == null) return;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (displayName != null) updates['display_name'] = displayName;
    if (paymentVpa != null) updates['payment_vpa'] = paymentVpa;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await c.from('profiles').update(updates).eq('id', user.id);

    // Also update auth user metadata
    await c.auth.updateUser(
      UserAttributes(
        data: {
          if (displayName != null) 'display_name': displayName,
          if (paymentVpa != null) 'payment_vpa': paymentVpa,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      ),
    );
  }
}
