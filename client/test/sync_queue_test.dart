import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/core/sync/sync_engine.dart';

void main() {
  late AppDatabase db;
  late Dio dio;
  late SyncEngine syncEngine;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dio = Dio();
    syncEngine = SyncEngine(db: db, dio: dio);
  });

  tearDown(() async {
    await db.close();
  });

  test('OutboundSyncQueue holds offline updates and persists across queries', () async {
    // 1. User performs 2 mutations while offline
    await db.into(db.outboundSyncQueue).insert(
          OutboundSyncQueueCompanion.insert(
            tripId: 'goa-2026',
            crdtUpdate: Uint8List.fromList([10, 20, 30]),
          ),
        );

    await db.into(db.outboundSyncQueue).insert(
          OutboundSyncQueueCompanion.insert(
            tripId: 'goa-2026',
            crdtUpdate: Uint8List.fromList([40, 50, 60]),
          ),
        );

    // 2. Query queue: should have 2 pending items
    final pending = await (db.select(db.outboundSyncQueue)
          ..where((t) => t.tripId.equals('goa-2026') & t.status.equals('pending')))
        .get();

    expect(pending.length, 2);
    expect(pending[0].crdtUpdate, [10, 20, 30]);
    expect(pending[1].crdtUpdate, [40, 50, 60]);
  });

  test('SyncEngine handles offline network failure gracefully without data loss', () async {
    // 1. Queue an update
    await db.into(db.outboundSyncQueue).insert(
          OutboundSyncQueueCompanion.insert(
            tripId: 'goa-2026',
            crdtUpdate: Uint8List.fromList([1, 2, 3]),
          ),
        );

    // 2. Attempt sync to an unreachable port (simulating offline mode)
    final success = await syncEngine.flushQueue(
      tripId: 'goa-2026',
      baseUrl: 'http://127.0.0.1:59999', // Closed port
    );

    expect(success, false);

    // 3. Mutation MUST still exist in database for next retry
    final itemsStillInQueue = await db.select(db.outboundSyncQueue).get();
    expect(itemsStillInQueue.length, 1);
    expect(itemsStillInQueue.first.crdtUpdate, [1, 2, 3]);
  });
}
