import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/supabase_auth_service.dart';
import '../data/app_error.dart';
import '../data/trip_repository.dart';

class SyncStatus {
  final bool busy;
  final String? error;
  final DateTime? lastSynced;
  const SyncStatus({this.busy = false, this.error, this.lastSynced});
}

final syncEngineProvider = StateNotifierProvider<SyncEngine, SyncStatus>((ref) =>
  SyncEngine(ref.watch(tripRepositoryProvider), ref.watch(supabaseClientProvider)));

class SyncEngine extends StateNotifier<SyncStatus> with WidgetsBindingObserver {
  final TripRepository repository;
  final SupabaseClient? client;
  Timer? _timer;
  Timer? _debounce;
  StreamSubscription<dynamic>? _queue;
  RealtimeChannel? _channel;
  bool _stopped = false;
  SyncEngine(this.repository, this.client) : super(const SyncStatus()) {
    if (repository.userId.isEmpty || client == null) return;
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => sync());
    _queue = repository.db.select(repository.db.outboundSyncQueue).watch().listen((_) => _schedule());
    _channel = client!.channel('ledger:${repository.userId}')
      .onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public',
        callback: (_) => _schedule())..subscribe();
    _schedule();
  }
  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), sync);
  }
  Future<void> sync() async {
    if (_stopped || state.busy) return;
    state = SyncStatus(busy: true, lastSynced: state.lastSynced);
    try {
      await repository.sync();
      if (!_stopped) state = SyncStatus(lastSynced: DateTime.now());
    } catch (e) {
      if (!_stopped) state = SyncStatus(error: appError(e), lastSynced: state.lastSynced);
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) sync();
  }
  @override
  void dispose() {
    _stopped = true;
    _timer?.cancel(); _debounce?.cancel(); _queue?.cancel();
    if (_channel != null) client?.removeChannel(_channel!);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
