import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/data/trip_repository.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/core/domain/money.dart';

class FakeCloud implements TripCloud {
  bool offline = true;
  bool published = false;
  final commands = <Map<String, dynamic>>[];
  @override
  Future<void> apply(Map<String, dynamic> command) async {
    if (offline) throw StateError('Offline');
    commands.add(command);
  }
  @override
  Future<List<Map<String, dynamic>>> trips() async => [{'id': 'trip'}];
  @override
  Future<Map<String, dynamic>> snapshot(String id) async {
    final command = commands.last;
    return {
      'trip': {'id': 'trip', 'name': 'Weekend', 'invite_code': 'ABC123',
        'base_currency': 'INR', 'status': 'active', 'created_by': 'alice'},
      'members': [
        {'id': 'm1', 'user_id': 'alice', 'display_name': 'Alice', 'role': 'creator'},
        {'id': 'm2', 'user_id': 'bob', 'display_name': 'Bob', 'role': 'member'},
      ],
      'expenses': published ? [{
        'id': command['id'], 'trip_id': 'trip', 'title': command['title'],
        'amount_minor': command['amount_minor'], 'currency': 'INR',
        'paid_by_user_id': 'alice', 'split_method': 'equal', 'category': 'other',
        'tax_minor': 0, 'service_charge_minor': 0,
        'created_by_user_id': 'alice', 'created_at': '2026-10-08T00:00:00Z',
      }] : [],
      'splits': published ? [for (final s in command['splits'])
        {'expense_id': command['id'], 'user_id': s['user_id'],
          'amount_minor': s['amount_minor']}] : [],
      'items': [], 'claims': [], 'settlements': [], 'itinerary': [],
    };
  }
}

void main() {
  test('expense stays local until server snapshot confirms its exact ID', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final cloud = FakeCloud();
    final repo = TripRepository(db: db, userId: 'alice', cloud: cloud);
    await db.into(db.localTrips).insert(LocalTripsCompanion.insert(
        id: 'trip', name: 'Weekend', inviteCode: 'ABC123'));
    await db.into(db.localMembers).insert(LocalMembersCompanion.insert(
        id: 'm1', tripId: 'trip', displayName: 'Alice', userId: const Value('alice')));
    await db.into(db.localMembers).insert(LocalMembersCompanion.insert(
        id: 'm2', tripId: 'trip', displayName: 'Bob', userId: const Value('bob')));
    final id = await repo.saveExpense(tripId: 'trip', title: 'Cab',
        amountMinor: 10001, payerId: 'm1',
        splits: splitEqually(10001, ['m1', 'm2']));
    expect((await repo.read()).balances('trip'), {'m1': 5000, 'm2': -5000});
    await expectLater(repo.sync(), throwsStateError);
    expect((await db.select(db.outboundSyncQueue).get()).length, 1);

    cloud.offline = false;
    await repo.sync();
    expect((await db.select(db.outboundSyncQueue).get()).length, 1);
    expect((await repo.read()).expenses.single.id, id);

    cloud.published = true;
    await repo.sync();
    expect(cloud.commands.every((command) => command['id'] == id), isTrue);
    expect(await db.select(db.outboundSyncQueue).get(), isEmpty);
    expect((await repo.read()).balances('trip'), {'m1': 5000, 'm2': -5000});
    await db.close();
  });
}
