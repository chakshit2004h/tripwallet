import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_provider.dart';

/// Reactive stream provider emitting the number of unsynced offline mutations.
final pendingSyncCountProvider = StreamProvider.autoDispose<int>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.outboundSyncQueue)
        ..where((tbl) => tbl.status.equals('pending')))
      .watch()
      .map((items) => items.length);
});
