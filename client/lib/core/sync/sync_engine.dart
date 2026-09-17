import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(databaseProvider);
  final dio = Dio();
  return SyncEngine(db: db, dio: dio);
});

class SyncEngine {
  final AppDatabase db;
  final Dio dio;

  SyncEngine({required this.db, required this.dio});

  /// Flushes all pending outbound updates for a given trip to the sync endpoint.
  Future<bool> flushQueue({
    required String tripId,
    String baseUrl = 'http://127.0.0.1:8080',
    String? clientStateVectorBase64,
  }) async {
    // 1. Fetch pending mutations from local SQLite queue
    final pendingItems = await (db.select(db.outboundSyncQueue)
          ..where((tbl) => tbl.tripId.equals(tripId) & tbl.status.equals('pending')))
        .get();

    if (pendingItems.isEmpty) {
      return true;
    }

    // 2. Base64 encode the binary CRDT updates
    final updatesBase64 = pendingItems
        .map((item) => base64Encode(item.crdtUpdate))
        .toList();

    final payload = {
      'client_state_vector': clientStateVectorBase64 ?? '',
      'pending_updates': updatesBase64,
    };

    try {
      final response = await dio.post(
        '$baseUrl/v1/trips/$tripId/sync',
        data: payload,
        options: Options(
          headers: {'content-type': 'application/json'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        // 3. Successfully synced: remove processed items from local queue
        final idsToDelete = pendingItems.map((item) => item.id).toList();
        await (db.delete(db.outboundSyncQueue)
              ..where((tbl) => tbl.id.isIn(idsToDelete)))
            .go();

        return true;
      }
      return false;
    } catch (_) {
      // Offline / network failure: items remain safely in OutboundSyncQueue for retry
      return false;
    }
  }
}
