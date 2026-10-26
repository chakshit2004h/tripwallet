import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../auth/supabase_auth_service.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';
import '../domain/ledger.dart';
import '../domain/expense_members.dart';

abstract class TripCloud {
  Future<List<Map<String, dynamic>>> trips();
  Future<Map<String, dynamic>> snapshot(String tripId);
  Future<void> apply(Map<String, dynamic> command);
}

class SupabaseTripCloud implements TripCloud {
  final SupabaseClient client;
  SupabaseTripCloud(this.client);
  @override
  Future<List<Map<String, dynamic>>> trips() async =>
      await client.from('trips').select().order('created_at', ascending: false);
  @override
  Future<Map<String, dynamic>> snapshot(String tripId) async =>
      Map<String, dynamic>.from(await client.rpc('trip_snapshot', params: {'p_trip': tripId}));
  @override
  Future<void> apply(Map<String, dynamic> command) async {
    await client.rpc('apply_command', params: {'p_command': command});
  }
}

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final repository = TripRepository(
    db: ref.watch(databaseProvider),
    userId: ref.watch(accountIdProvider) ?? '',
    cloud: client == null ? null : SupabaseTripCloud(client),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final ledgerProvider = StreamProvider<LedgerData>((ref) =>
    ref.watch(tripRepositoryProvider).watch());

class LedgerData {
  final List<LocalTrip> trips;
  final List<LocalMember> members;
  final List<LocalExpense> expenses;
  final List<LocalExpenseSplit> splits;
  final List<LocalSettlement> settlements;
  final List<LocalItineraryStop> stops;
  final List<OutboundSyncQueueData> pending;
  const LedgerData(this.trips, this.members, this.expenses, this.splits,
      this.settlements, this.stops, this.pending);

  Map<String, int> balances(String tripId) => calculateBalances(
      members.where((m) => m.tripId == tripId).toList(),
      expenses.where((e) => e.tripId == tripId).toList(), splits,
      settlements.where((s) => s.tripId == tripId).toList());
  String memberName(String id) => members.where((m) => m.id == id)
      .map((m) => m.displayName).firstOrNull ?? 'Former member';
  String? myMemberId(String tripId, String userId) => members
      .where((m) => m.tripId == tripId && m.userId == userId)
      .map((m) => m.id).firstOrNull;
}

class TripRepository {
  final AppDatabase db;
  final String userId;
  final TripCloud? cloud;
  Future<void>? _inFlight;
  bool _disposed = false;
  TripRepository({required this.db, required this.userId, this.cloud});
  void dispose() { _disposed = true; }

  Stream<LedgerData> watch() => db.customSelect('SELECT 1', readsFrom: {
    db.localTrips, db.localMembers, db.localExpenses, db.localExpenseSplits,
    db.localSettlements, db.localItineraryStops, db.outboundSyncQueue,
  }).watch().asyncMap((_) => read());

  Future<LedgerData> read() => db.transaction(() async => LedgerData(
    await (db.select(db.localTrips)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get(),
    await db.select(db.localMembers).get(),
    await (db.select(db.localExpenses)..orderBy([(e) => OrderingTerm.desc(e.createdAt)])).get(),
    await db.select(db.localExpenseSplits).get(),
    await db.select(db.localSettlements).get(),
    await (db.select(db.localItineraryStops)..orderBy([(s) => OrderingTerm.asc(s.time)])).get(),
    await db.select(db.outboundSyncQueue).get(),
  ));

  Future<LocalTrip> _activeTrip(String id) async {
    final trip = await (db.select(db.localTrips)..where((t) => t.id.equals(id))).getSingle();
    if (trip.status != 'active') throw StateError('Restore this trip before making changes.');
    if (userId.isEmpty) throw StateError('Sign in to continue.');
    return trip;
  }

  Future<Map<String, LocalMember>> _members(String tripId) async => {
    for (final m in await (db.select(db.localMembers)..where((m) => m.tripId.equals(tripId))).get()) m.id: m,
  };

  Future<void> _enqueue(String tripId, Map<String, dynamic> command) async {
    command['command_id'] = const Uuid().v4();
    command['trip_id'] = tripId;
    await db.into(db.outboundSyncQueue).insert(OutboundSyncQueueCompanion.insert(
      tripId: tripId, crdtUpdate: Uint8List.fromList(utf8.encode(jsonEncode(command))),
    ));
  }

  Future<String> saveExpense({required String tripId, required String title,
    required int amountMinor, required String payerId, required Map<String, int> splits,
    String category = 'other', String splitMethod = 'equal', int taxMinor = 0,
    int serviceChargeMinor = 0, List<Map<String, dynamic>> items = const [], String? id,
  }) async {
    final trip = await _activeTrip(tripId);
    final members = await _members(tripId);
    if (title.trim().isEmpty || title.length > 120 || amountMinor <= 0 || amountMinor > 100000000000 ||
        !members.containsKey(payerId) || splits.isEmpty ||
        splits.keys.any((id) => !members.containsKey(id)) ||
        splits.values.any((amount) => amount < 0) ||
        splits.values.fold(0, (a,b) => a+b) != amountMinor) {
      throw const FormatException('Check the amount, payer and member shares.');
    }
    if (!canShareNewExpense(members[payerId]!) ||
        splits.keys.any((id) => !canShareNewExpense(members[id]!))) {
      throw const FormatException('Deleted accounts cannot share a new expense. Refresh the trip members.');
    }
    final expenseId = id ?? const Uuid().v4();
    final command = <String, dynamic>{'kind': 'expense', 'id': expenseId,
      'title': title.trim(), 'amount_minor': amountMinor, 'currency': trip.baseCurrency,
      'paid_by_user_id': members[payerId]!.userId, 'category': category,
      'split_method': splitMethod, 'tax_minor': taxMinor, 'service_charge_minor': serviceChargeMinor,
      'splits': [for (final s in splits.entries) {'user_id': members[s.key]!.userId, 'amount_minor': s.value}],
      'items': [for (final item in items) {...item,
        'claimed_by_user_ids': [for (final id in item['member_ids'] as List<String>) members[id]!.userId],
      }],
    };
    await db.transaction(() async {
      await db.into(db.localExpenses).insert(LocalExpensesCompanion.insert(
        id: expenseId, tripId: tripId, title: title.trim(), amountMinor: amountMinor,
        currency: trip.baseCurrency, paidByMemberId: payerId, category: Value(category),
        splitMethod: Value(splitMethod), taxMinor: Value(taxMinor),
        serviceChargeMinor: Value(serviceChargeMinor), createdBy: Value(userId),
      ));
      for (final split in splits.entries) {
        await db.into(db.localExpenseSplits).insert(LocalExpenseSplitsCompanion.insert(
          expenseId: expenseId, memberId: split.key, amountMinor: split.value));
      }
      for (final item in items) {
        await db.into(db.localLineItems).insert(LocalLineItemsCompanion.insert(
          id: item['id'], expenseId: expenseId, label: item['label'], priceMinor: item['price_minor']));
        final claims = item['member_ids'] as List<String>;
        for (final member in claims) {
          await db.into(db.localItemClaims).insert(LocalItemClaimsCompanion.insert(
            id: '${item['id']}_$member', lineItemId: item['id'], memberId: member,
            shareFraction: Value(1 / claims.length)));
        }
      }
      await _enqueue(tripId, command);
    });
    return expenseId;
  }

  Future<void> settle({required String tripId, required String fromMemberId,
    required String toMemberId, required int amountMinor, required String method}) async {
    final trip = await _activeTrip(tripId);
    final members = await _members(tripId);
    if (members[fromMemberId]?.userId != userId || !members.containsKey(toMemberId) ||
        fromMemberId == toMemberId || amountMinor <= 0) {
      throw StateError('Only the payer can record this settlement.');
    }
    final id = const Uuid().v4();
    await db.transaction(() async {
      await db.into(db.localSettlements).insert(LocalSettlementsCompanion.insert(
        id: id, tripId: tripId, fromMemberId: fromMemberId, toMemberId: toMemberId,
        amountMinor: amountMinor, currency: Value(trip.baseCurrency), method: Value(method)));
      await _enqueue(tripId, {'kind':'settlement','id':id,'from_user_id':userId,
        'to_user_id':members[toMemberId]!.userId,'amount_minor':amountMinor,
        'currency':trip.baseCurrency,'method':method});
    });
  }

  Future<void> addStop({required String tripId, required int dayIndex, required String time,
    required String title, required String subtitle, required String type, String? bookingRef}) async {
    await _activeTrip(tripId);
    if (title.trim().isEmpty || !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(time)) {
      throw const FormatException('Enter a title and time in HH:MM format.');
    }
    final id = const Uuid().v4();
    await db.transaction(() async {
      await db.into(db.localItineraryStops).insert(LocalItineraryStopsCompanion.insert(
        id:id,tripId:tripId,dayIndex:dayIndex,time:time,title:title.trim(),subtitle:subtitle,
        type:type,bookingRef:Value(bookingRef)));
      await _enqueue(tripId, {'kind':'itinerary','id':id,'day_index':dayIndex,
        'time':time,'title':title.trim(),'subtitle':subtitle,'type':type,'booking_ref':bookingRef});
    });
  }

  Future<void> deleteExpense(LocalExpense expense) async {
    final trip = await _activeTrip(expense.tripId);
    if (expense.createdBy != userId && trip.createdBy != userId) {
      throw StateError('Only the author or trip creator can delete this expense.');
    }
    await db.transaction(() async {
      await _deleteExpenseRows([expense.id]);
      await _enqueue(expense.tripId, {'kind':'delete_expense','id':expense.id});
    });
  }

  Future<void> _deleteExpenseRows(List<String> ids) async {
    final lines = await (db.select(db.localLineItems)..where((l) => l.expenseId.isIn(ids))).get();
    await (db.delete(db.localItemClaims)..where((c) => c.lineItemId.isIn(lines.map((l) => l.id)))).go();
    await (db.delete(db.localLineItems)..where((l) => l.expenseId.isIn(ids))).go();
    await (db.delete(db.localExpenseSplits)..where((s) => s.expenseId.isIn(ids))).go();
    await (db.delete(db.localExpenses)..where((e) => e.id.isIn(ids))).go();
  }

  Future<void> removeTrip(String tripId) => db.transaction(() async {
    final expenses = await (db.select(db.localExpenses)..where((e) => e.tripId.equals(tripId))).get();
    await _deleteExpenseRows(expenses.map((e) => e.id).toList());
    await (db.delete(db.localSettlements)..where((s) => s.tripId.equals(tripId))).go();
    await (db.delete(db.localItineraryStops)..where((s) => s.tripId.equals(tripId))).go();
    await (db.delete(db.localMembers)..where((m) => m.tripId.equals(tripId))).go();
    await (db.delete(db.localAlerts)..where((m) => m.tripId.equals(tripId))).go();
    await (db.delete(db.localTrips)..where((t) => t.id.equals(tripId))).go();
  });

  /// Serialized to prevent a stale pull overwriting an acknowledged mutation.
  Future<void> sync() {
    if (_inFlight != null) return _inFlight!;
    final future = _sync();
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<void> _sync() async {
    if (_disposed || userId.isEmpty || cloud == null) return;
    final pending = await (db.select(db.outboundSyncQueue)..orderBy([(q) => OrderingTerm.asc(q.id)])).get();
    for (final row in pending) {
      if (_disposed) return;
      final command = Map<String, dynamic>.from(jsonDecode(utf8.decode(row.crdtUpdate)));
      await cloud!.apply(command);
      if (_disposed) return;
    }
    final trips = await cloud!.trips();
    if (_disposed) return;
    for (final trip in trips) {
      final snapshot = await cloud!.snapshot(trip['id']);
      if (_disposed) return;
      final tripPending = pending.where((row) => row.tripId == trip['id']).toList();
      final latestById = <String, Map<String, dynamic>>{};
      for (final row in tripPending) {
        final command = Map<String, dynamic>.from(jsonDecode(utf8.decode(row.crdtUpdate)));
        latestById[command['id'] as String] = command;
      }
      final confirmedIds = <String>{};
      for (final entry in latestById.entries) {
        if (_commandVisible(snapshot, entry.value)) confirmedIds.add(entry.key);
      }
      await applySnapshot(snapshot, acknowledgedQueueIds: {
        for (final row in tripPending)
          if (confirmedIds.contains(jsonDecode(utf8.decode(row.crdtUpdate))['id'])) row.id,
      });
    }
    final remoteIds = trips.map((t) => t['id'] as String).toSet();
    for (final local in await db.select(db.localTrips).get()) {
      if (!remoteIds.contains(local.id)) {
        final queued = await (db.select(db.outboundSyncQueue)..where((q) => q.tripId.equals(local.id))).get();
        if (queued.isEmpty) await removeTrip(local.id);
      }
    }
  }

  bool _commandVisible(Map<String, dynamic> snapshot, Map<String, dynamic> command) {
    final kind = command['kind'];
    final key = switch (kind) {
      'expense' || 'delete_expense' => 'expenses',
      'settlement' => 'settlements',
      'itinerary' || 'delete_itinerary' => 'itinerary',
      _ => '',
    };
    if (key.isEmpty) return false;
    final present = (snapshot[key] as List? ?? []).any((row) => row['id'] == command['id']);
    return kind == 'delete_expense' || kind == 'delete_itinerary' ? !present : present;
  }

  /// Replace each trip atomically, preserving writes made while a request was in flight.
  Future<void> applySnapshot(Map<String, dynamic> data, {Set<int> acknowledgedQueueIds = const {}}) => db.transaction(() async {
    final t = Map<String,dynamic>.from(data['trip']);
    final tid = t['id'] as String;
    if (acknowledgedQueueIds.isNotEmpty) {
      await (db.delete(db.outboundSyncQueue)..where((q) => q.id.isIn(acknowledgedQueueIds))).go();
    }
    List<Map<String,dynamic>> rows(String key) => (data[key] as List? ?? [])
        .map((v) => Map<String,dynamic>.from(v)).toList();
    final queue = await (db.select(db.outboundSyncQueue)..where((q) => q.tripId.equals(tid))).get();
    final protected = queue.map((q) => jsonDecode(utf8.decode(q.crdtUpdate))['id']).toSet();
    await db.into(db.localTrips).insertOnConflictUpdate(LocalTripsCompanion.insert(
      id:tid,name:t['name'],inviteCode:t['invite_code'],baseCurrency:Value(t['base_currency']),
      status:Value(t['status']),createdBy:Value(t['created_by']),
      startDate:Value(DateTime.tryParse(t['start_date'] ?? '')),
      endDate:Value(DateTime.tryParse(t['end_date'] ?? ''))));
    final memberMap = {for(final m in rows('members')) m['user_id'] as String: m['id'] as String};
    String member(dynamic user) => memberMap[user] ?? (throw StateError('Missing trip member'));
    await (db.delete(db.localMembers)..where((m) => m.tripId.equals(tid))).go();
    for (final m in rows('members')) {
      await db.into(db.localMembers).insert(LocalMembersCompanion.insert(
        id:m['id'],tripId:tid,userId:Value(m['user_id']),displayName:m['display_name'],
        role:Value(m['role']),paymentVpa:Value(m['payment_vpa']),avatarUrl:Value(m['avatar_url'])));
    }
    final oldExpenses = await (db.select(db.localExpenses)..where((e) => e.tripId.equals(tid))).get();
    await _deleteExpenseRows(oldExpenses.where((e) => !protected.contains(e.id)).map((e) => e.id).toList());
    for (final e in rows('expenses').where((e) => !protected.contains(e['id']))) {
      await db.into(db.localExpenses).insert(LocalExpensesCompanion.insert(
        id:e['id'],tripId:tid,title:e['title'],amountMinor:e['amount_minor'],currency:e['currency'],
        paidByMemberId:member(e['paid_by_user_id']),splitMethod:Value(e['split_method']),
        category:Value(e['category']),taxMinor:Value(e['tax_minor']),serviceChargeMinor:Value(e['service_charge_minor']),
        createdBy:Value(e['created_by_user_id']),createdAt:Value(DateTime.parse(e['created_at']))));
    }
    for (final s in rows('splits').where((s) => !protected.contains(s['expense_id']))) {
      await db.into(db.localExpenseSplits).insert(LocalExpenseSplitsCompanion.insert(
        expenseId:s['expense_id'],memberId:member(s['user_id']),amountMinor:s['amount_minor']));
    }
    final lineIds = <String>{};
    for (final l in rows('items').where((l) => !protected.contains(l['expense_id']))) {
      lineIds.add(l['id']);
      await db.into(db.localLineItems).insert(LocalLineItemsCompanion.insert(
        id:l['id'],expenseId:l['expense_id'],label:l['label'],priceMinor:l['price_minor']));
    }
    for (final c in rows('claims').where((c) => lineIds.contains(c['line_item_id']))) {
      await db.into(db.localItemClaims).insert(LocalItemClaimsCompanion.insert(
        id:c['id'],lineItemId:c['line_item_id'],memberId:member(c['user_id']),
        shareFraction:Value((c['share_fraction'] as num).toDouble())));
    }
    await (db.delete(db.localSettlements)..where((s) => s.tripId.equals(tid) & s.id.isNotIn(protected.whereType<String>()))).go();
    for (final s in rows('settlements').where((s) => !protected.contains(s['id']))) {
      await db.into(db.localSettlements).insert(LocalSettlementsCompanion.insert(
        id:s['id'],tripId:tid,fromMemberId:member(s['from_user_id']),toMemberId:member(s['to_user_id']),
        amountMinor:s['amount_minor'],currency:Value(s['currency']),method:Value(s['method']),
        status:Value(s['status']),createdAt:Value(DateTime.parse(s['created_at']))));
    }
    await (db.delete(db.localItineraryStops)..where((s) => s.tripId.equals(tid) & s.id.isNotIn(protected.whereType<String>()))).go();
    for (final s in rows('itinerary').where((s) => !protected.contains(s['id']))) {
      await db.into(db.localItineraryStops).insert(LocalItineraryStopsCompanion.insert(
        id:s['id'],tripId:tid,dayIndex:s['day_index'],time:s['time'],title:s['title'],
        subtitle:s['subtitle'],type:s['type'],bookingRef:Value(s['booking_ref'])));
    }
  });
}
