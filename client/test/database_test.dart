import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('LocalTrips and OutboundSyncQueue CRUD operations', () async {
    // 1. Insert a trip into local Drift database
    await db.into(db.localTrips).insert(
          LocalTripsCompanion.insert(
            id: 'trip-101',
            inviteCode: 'GOA2026',
            name: 'Goa Vacation',
            baseCurrency: const Value('INR'),
          ),
        );

    final trips = await db.select(db.localTrips).get();
    expect(trips.length, 1);
    expect(trips.first.name, 'Goa Vacation');
    expect(trips.first.inviteCode, 'GOA2026');

    // 2. Queue an offline CRDT update
    await db.into(db.outboundSyncQueue).insert(
          OutboundSyncQueueCompanion.insert(
            tripId: 'trip-101',
            crdtUpdate: Uint8List.fromList([1, 2, 3, 4]),
          ),
        );

    final queue = await db.select(db.outboundSyncQueue).get();
    expect(queue.length, 1);
    expect(queue.first.status, 'pending');
    expect(queue.first.tripId, 'trip-101');
  });
}
