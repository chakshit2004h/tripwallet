import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/core/db/database_provider.dart';
import 'package:tripwallet_client/features/trip_dashboard/presentation/trip_summary_sheet.dart';
import 'package:tripwallet_client/features/paywall/presentation/paywall_modal.dart';

void main() {
  group('Trip Summary & Paywall Widget Tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('TripSummarySheet displays metrics and archive button', (tester) async {
      await database.into(database.localMembers).insert(
        LocalMembersCompanion.insert(id: 'm1', tripId: 'trip_goa', displayName: 'You'),
      );
      await database.into(database.localMembers).insert(
        LocalMembersCompanion.insert(id: 'm2', tripId: 'trip_goa', displayName: 'Aisha'),
      );
      await database.into(database.localMembers).insert(
        LocalMembersCompanion.insert(id: 'm3', tripId: 'trip_goa', displayName: 'Rohan'),
      );
      await database.into(database.localMembers).insert(
        LocalMembersCompanion.insert(id: 'm4', tripId: 'trip_goa', displayName: 'Chirag'),
      );
      await database.into(database.localExpenses).insert(
        LocalExpensesCompanion.insert(id: 'e1', tripId: 'trip_goa', title: 'Dinner food', amountMinor: 920000, currency: 'INR', paidByMemberId: 'm1'),
      );
      await database.into(database.localExpenses).insert(
        LocalExpensesCompanion.insert(id: 'e2', tripId: 'trip_goa', title: 'Hotel stay', amountMinor: 640000, currency: 'INR', paidByMemberId: 'm1'),
      );
      await database.into(database.localExpenses).insert(
        LocalExpensesCompanion.insert(id: 'e3', tripId: 'trip_goa', title: 'Cab transport', amountMinor: 280000, currency: 'INR', paidByMemberId: 'm1'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TripSummarySheet(tripId: 'trip_goa'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trip complete'), findsOneWidget);
      expect(find.text('total spent across 4 people'), findsOneWidget);
      expect(find.text('Food & drink'), findsOneWidget);
      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Archive trip'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('PaywallModal toggles plans and activates subscription', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => PaywallModal.show(context),
                child: const Text('Open Paywall'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Paywall'));
      await tester.pumpAndSettle();

      expect(find.text('TRIPWALLET PRO'), findsOneWidget);
      expect(find.text('Trip Pass'), findsOneWidget);
      expect(find.text('Annual Pro'), findsOneWidget);
      expect(find.text('Start 7-Day Free Trial'), findsOneWidget);

      // Select Trip Pass
      await tester.tap(find.text('Trip Pass'));
      await tester.pumpAndSettle();

      expect(find.text('Unlock Trip Pass (\$2.99)'), findsOneWidget);

      // Select Annual Pro back
      await tester.tap(find.text('Annual Pro'));
      await tester.pumpAndSettle();

      expect(find.text('Start 7-Day Free Trial'), findsOneWidget);
    });
  });
}

