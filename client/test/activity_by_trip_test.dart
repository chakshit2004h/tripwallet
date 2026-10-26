import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/data/trip_repository.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/features/alerts/presentation/alerts_screen.dart';

LocalTrip trip(String id, String name) => LocalTrip(
  id: id,
  inviteCode: 'CODE1234',
  createdBy: 'user',
  name: name,
  baseCurrency: 'INR',
  status: 'active',
  updatedAt: DateTime(2026),
);
LocalExpense expense(String id, String tripId, String title, int day) =>
    LocalExpense(
      category: 'other',
      createdBy: 'user',
      id: id,
      tripId: tripId,
      title: title,
      amountMinor: 10000,
      currency: 'INR',
      paidByMemberId: 'member',
      splitMethod: 'equal',
      taxMinor: 0,
      serviceChargeMinor: 0,
      createdAt: DateTime(2026, 10, day),
    );

void main() {
  Future<void> mount(WidgetTester tester, LedgerData data) async {
    tester.view.physicalSize = const Size(600, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [ledgerProvider.overrideWith((ref) => Stream.value(data))],
        child: const MaterialApp(home: AlertsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('no trips retains the existing empty state', (tester) async {
    await mount(tester, const LedgerData([], [], [], [], [], [], []));
    expect(find.text('A fresh start'), findsOneWidget);
    expect(find.text('Activity by trip'), findsNothing);
  });

  testWidgets('one trip retains a single chronological activity list', (
    tester,
  ) async {
    await mount(
      tester,
      LedgerData(
        [trip('a', 'Beach')],
        [],
        [
          expense('old', 'a', 'Older dinner', 1),
          expense('new', 'a', 'Latest lunch', 2),
        ],
        [],
        [],
        [],
        [],
      ),
    );
    expect(find.text('The latest from your trips.'), findsOneWidget);
    expect(find.byKey(const ValueKey('activity-trip-a')), findsNothing);
    expect(find.text('Beach'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Latest lunch')).dy,
      lessThan(tester.getTopLeft(find.text('Older dinner')).dy),
    );
  });

  testWidgets(
    'multiple trips separate expenses and payments and include empty trips',
    (tester) async {
      await mount(
        tester,
        LedgerData(
          [
            trip('a', 'Beach'),
            trip('b', 'Mountains'),
            trip('c', 'Next holiday'),
          ],
          [],
          [
            expense('a1', 'a', 'Beach dinner', 1),
            expense('b1', 'b', 'Mountain taxi', 3),
            expense('a2', 'a', 'Beach hotel', 2),
          ],
          [],
          [
            LocalSettlement(
              id: 'payment',
              tripId: 'b',
              fromMemberId: 'm1',
              toMemberId: 'm2',
              amountMinor: 5000,
              currency: 'INR',
              method: 'cash',
              status: 'confirmed',
              createdAt: DateTime(2026, 10, 4),
            ),
          ],
          [],
          [],
        ),
      );
      final beach = find.byKey(const ValueKey('activity-trip-a'));
      final mountains = find.byKey(const ValueKey('activity-trip-b'));
      final next = find.byKey(const ValueKey('activity-trip-c'));
      expect(find.text('Activity by trip'), findsOneWidget);
      expect(
        find.descendant(of: beach, matching: find.text('Beach dinner')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: beach, matching: find.text('Mountain taxi')),
        findsNothing,
      );
      expect(
        find.descendant(of: mountains, matching: find.text('Mountain taxi')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: mountains, matching: find.text('Payment recorded')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: beach, matching: find.text('Payment recorded')),
        findsNothing,
      );
      expect(
        find.descendant(of: next, matching: find.text('No activity yet')),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.text('Beach hotel')).dy,
        lessThan(tester.getTopLeft(find.text('Beach dinner')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Payment recorded')).dy,
        lessThan(tester.getTopLeft(find.text('Mountain taxi')).dy),
      );
    },
  );
}
