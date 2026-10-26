import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/supabase_auth_service.dart';
import 'app_database.dart';

final accountIdProvider = Provider<String?>((ref) {
  final state = ref.watch(authStateStreamProvider);
  return state.asData?.value.session?.user.id ??
      ref.watch(supabaseAuthServiceProvider).currentUserId;
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final accountId = ref.watch(accountIdProvider);
  final db = AppDatabase(accountId: accountId ?? 'signed-out');
  ref.onDispose(() => db.close());
  return db;
});
