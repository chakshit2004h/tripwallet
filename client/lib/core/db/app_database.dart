import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class LocalTrips extends Table {
  TextColumn get id => text()();
  TextColumn get inviteCode => text()();
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get baseCurrency => text().withDefault(const Constant('INR'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BlobColumn get crdtSnapshot => blob().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMembers extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get displayName => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('member'))();
  TextColumn get paymentVpa => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get title => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get paidByMemberId => text()();
  TextColumn get splitMethod => text().withDefault(const Constant('equal'))();
  IntColumn get taxMinor => integer().withDefault(const Constant(0))();
  IntColumn get serviceChargeMinor => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalLineItems extends Table {
  TextColumn get id => text()();
  TextColumn get expenseId => text()();
  TextColumn get label => text()();
  IntColumn get priceMinor => integer()();
  RealColumn get ocrConfidence => real().withDefault(const Constant(1.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalItemClaims extends Table {
  TextColumn get id => text()();
  TextColumn get lineItemId => text()();
  TextColumn get memberId => text()();
  RealColumn get shareFraction => real().withDefault(const Constant(1.0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Durable offline queue for CRDT mutations awaiting server sync.
class OutboundSyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tripId => text()();
  BlobColumn get crdtUpdate => blob()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text().withDefault(const Constant('pending'))();
}

class LocalSettlements extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get fromMemberId => text()();
  TextColumn get toMemberId => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get method => text().withDefault(const Constant('upi'))();
  TextColumn get status => text().withDefault(const Constant('confirmed'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalItineraryStops extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  IntColumn get dayIndex => integer()();
  TextColumn get time => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text()();
  TextColumn get type => text()(); // flight, hotel, food, activity
  TextColumn get bookingRef => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get title => text()();
  TextColumn get timeAgo => text()();
  TextColumn get iconType => text()(); // wallet, receipt, user
  BoolColumn get isCoral => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  LocalTrips,
  LocalMembers,
  LocalExpenses,
  LocalLineItems,
  LocalItemClaims,
  LocalSettlements,
  OutboundSyncQueue,
  LocalItineraryStops,
  LocalAlerts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(localItineraryStops);
            await m.createTable(localAlerts);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tripwallet.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
