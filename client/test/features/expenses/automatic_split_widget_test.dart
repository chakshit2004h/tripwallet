import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:go_router/go_router.dart';
import 'package:tripwallet_client/core/data/trip_repository.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/core/db/database_provider.dart';
import 'package:tripwallet_client/features/expenses/presentation/manual_expense_screen.dart';

class CapturingRepository extends TripRepository {
  CapturingRepository(AppDatabase db) : super(db: db, userId: 'p1');
  Map<String, int>? savedShares;
  int? savedAmount;
  @override
  Future<String> saveExpense({
    required String tripId,
    required String title,
    required int amountMinor,
    required String payerId,
    required Map<String, int> splits,
    String category = 'other',
    String splitMethod = 'equal',
    int taxMinor = 0,
    int serviceChargeMinor = 0,
    List<Map<String, dynamic>> items = const [],
    String? id,
  }) async {
    savedShares = Map.of(splits);
    savedAmount = amountMinor;
    return 'saved';
  }
}

void main() {
  testWidgets(
    'automatic shares recalculate, validate and save the displayed split',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = CapturingRepository(db);
      final data = LedgerData(
        [
          LocalTrip(
            id: 'trip',
            inviteCode: 'CODE',
            createdBy: 'p1',
            name: 'Trip',
            baseCurrency: 'INR',
            status: 'active',
            updatedAt: DateTime(2026),
          ),
        ],
        [
          for (final id in ['p1', 'p2', 'p3'])
            LocalMember(
              userId: id,
              id: id,
              tripId: 'trip',
              displayName: id,
              role: 'member',
            ),
        ],
        [],
        [],
        [],
        [],
        [],
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Trip home')),
          ),
          GoRoute(
            path: '/expense',
            builder: (_, __) => const ManualExpenseScreen(tripId: 'trip'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ledgerProvider.overrideWith((ref) => Stream.value(data)),
            accountIdProvider.overrideWithValue('p1'),
            tripRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      router.push('/expense');
      await tester.pumpAndSettle();
      Finder share(String id) => find.byKey(ValueKey('share-$id'));
      String? auto(String id) =>
          tester.widget<TextField>(share(id)).decoration?.hintText;
      Future<void> enter(String id, String value) async {
        await tester.enterText(share(id), value);
        await tester.pump();
      }

      await tester.enterText(find.byType(TextField).first, 'Dinner');
      await tester.enterText(
        find.byKey(const ValueKey('expense-amount')),
        '1000',
      );
      await tester.tap(find.text('Exact'));
      await tester.pumpAndSettle();
      expect(auto('p1'), '333.34');
      await enter('p1', '400');
      expect(auto('p2'), '300.00');
      expect(auto('p3'), '300.00');
      await enter('p2', '250');
      expect(auto('p3'), '350.00');
      await tester.enterText(
        find.byKey(const ValueKey('expense-amount')),
        '1200',
      );
      await tester.pump();
      expect(auto('p3'), '550.00');
      await enter('p2', '');
      expect(auto('p2'), '400.00');
      expect(auto('p3'), '400.00');
      await tester.tap(find.byKey(const ValueKey('include-p2')));
      await tester.pump();
      expect(auto('p3'), '800.00');
      await tester.tap(find.byKey(const ValueKey('include-p2')));
      await tester.pump();
      expect(auto('p2'), '400.00');
      await enter('p1', '1300');
      expect(
        find.text('The shares you entered exceed the expense amount.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Save expense'),
            )
            .onPressed,
        isNull,
      );
      await enter('p1', '400');
      await enter('p2', '250');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save expense'));
      await tester.pumpAndSettle();
      expect(repo.savedAmount, 120000);
      expect(repo.savedShares, {'p1': 40000, 'p2': 25000, 'p3': 55000});
      expect(find.text('Trip home'), findsOneWidget);
    },
  );
}
