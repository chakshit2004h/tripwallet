import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:tripwallet_client/core/data/trip_repository.dart';
import 'package:tripwallet_client/core/db/app_database.dart';
import 'package:tripwallet_client/core/domain/expense_members.dart';
import 'package:tripwallet_client/features/expenses/domain/receipt_layout.dart';
import 'package:tripwallet_client/features/expenses/domain/receipt_models.dart';
import 'package:tripwallet_client/features/expenses/domain/receipt_parser.dart';
import 'package:tripwallet_client/features/expenses/presentation/item_claim_screen.dart';
import 'package:tripwallet_client/features/expenses/presentation/line_item_review_screen.dart';

ReceiptData photoReceipt() {
  final rows =
      jsonDecode(
            File('test/fixtures/receipt_table_ocr.json').readAsStringSync(),
          )
          as List;
  return parseReceiptText(
    receiptTextInReadingOrder(
      rows.map(
        (e) => ReceiptTextFragment(
          text: e['text'],
          left: (e['left'] as num).toDouble(),
          top: (e['top'] as num).toDouble(),
          right: (e['right'] as num).toDouble(),
          bottom: (e['bottom'] as num).toDouble(),
        ),
      ),
    ),
    tripId: 'trip',
    currency: 'INR',
    payerMemberId: 'alice',
  );
}

const people = [
  MemberProfile(id: 'alice', name: 'Alice', initial: 'A', color: Colors.green),
  MemberProfile(id: 'bob', name: 'Bob', initial: 'B', color: Colors.blue),
];

void main() {
  test(
    'saved receipt keeps tax and round-off, and rejects deleted participants',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await db
          .into(db.localTrips)
          .insert(
            LocalTripsCompanion.insert(
              id: 'trip',
              inviteCode: 'CODE',
              name: 'Trip',
            ),
          );
      for (final id in ['alice', 'bob', 'old']) {
        await db
            .into(db.localMembers)
            .insert(
              LocalMembersCompanion.insert(
                id: id,
                tripId: 'trip',
                userId: Value('$id-user'),
                displayName: id == 'old' ? 'Deleted account' : id,
              ),
            );
      }
      final repo = TripRepository(db: db, userId: 'alice-user');
      final receipt = photoReceipt();
      receipt.items[0].claimedMemberIds.add('alice');
      receipt.items[1].claimedMemberIds.add('bob');
      final shares = receiptAllocations(receipt, 'alice', people);
      await repo.saveExpense(
        tripId: 'trip',
        title: 'Receipt',
        amountMinor: receipt.totalMinor,
        payerId: 'alice',
        splits: {for (final e in shares.entries) e.key: e.value.totalMinor},
        splitMethod: 'itemized',
        taxMinor: receipt.taxMinor,
        items: [
          for (final i in receipt.items)
            {
              'id': i.id,
              'label': i.label,
              'price_minor': i.priceMinor,
              'member_ids': receiptItemClaims(receipt, i).toList(),
            },
        ],
      );
      final data = await repo.read();
      expect(data.expenses.single.taxMinor, 17190);
      expect(data.expenses.single.amountMinor, 112700);
      final command =
          jsonDecode(utf8.decode(data.pending.single.crdtUpdate)) as Map;
      expect(command['tax_minor'], 17190);
      expect((command['items'] as List).last['claimed_by_user_ids'], [
        'alice-user',
        'bob-user',
      ]);
      expect(data.memberName('old'), 'Deleted account');
      await expectLater(
        repo.saveExpense(
          tripId: 'trip',
          title: 'Invalid',
          amountMinor: 100,
          payerId: 'alice',
          splits: {'old': 100},
        ),
        throwsFormatException,
      );
      expect((await repo.read()).expenses, hasLength(1));
    },
  );

  test('real photo separates item columns, GST and round-off', () {
    final receipt = photoReceipt();
    expect(receipt.items.map((i) => i.label), [
      ':HAWARMA',
      "EL' RICE",
      'Round-off',
    ]);
    expect(receipt.items.first.quantity, 1);
    expect(receipt.items.first.unitPriceMinor, 61000);
    expect(receipt.items.first.taxRatePercent, '18.0');
    expect(receipt.subtotalMinor, 95500);
    expect(receipt.taxBreakdown, {'CGST': 8595, 'SGST': 8595});
    expect(receipt.taxMinor, 17190);
    expect(receipt.adjustmentMinor, 10);
    expect(receipt.totalMinor, 112700);
    expect(receipt.printedTotalMinor, 112700);
  });

  test('tax remains in unequal shares and round-off is not taxed', () {
    final receipt = photoReceipt();
    receipt.items[0].claimedMemberIds.add('alice');
    receipt.items[1].claimedMemberIds.add('bob');
    final shares = receiptAllocations(receipt, 'alice', people);
    expect(shares['alice']!.taxMinor, 10980);
    expect(shares['bob']!.taxMinor, 6210);
    expect(shares['alice']!.totalMinor, 71985);
    expect(shares['bob']!.totalMinor, 40715);
    expect(receiptItemClaims(receipt, receipt.items.last), {'alice', 'bob'});
    expect(
      receipt.items.fold(0, (sum, i) => sum + i.priceMinor) + receipt.taxMinor,
      receipt.totalMinor,
    );
  });

  test(
    'deleted membership is preserved for history but excluded from new expenses',
    () {
      const member = LocalMember(
        id: 'old',
        tripId: 'trip',
        userId: 'old-user',
        displayName: 'Deleted account',
        role: 'member',
      );
      expect(canShareNewExpense(member), isFalse);
      expect(canShareNewExpense(member.copyWith(displayName: 'Alice')), isTrue);
    },
  );

  testWidgets(
    'sharing shows GST and complete total without an adjustment claim',
    (tester) async {
      final receipt = photoReceipt();
      await tester.pumpWidget(
        MaterialApp(
          home: ItemClaimScreen(receipt: receipt, members: people),
        ),
      );
      expect(find.text('CGST'), findsOneWidget);
      expect(find.text('SGST'), findsOneWidget);
      expect(find.text('₹171.90'), findsOneWidget);
      expect(find.text('₹1127.00'), findsOneWidget);
      await tester.ensureVisible(find.text('Select everyone for all items'));
      await tester.tap(find.text('Select everyone for all items'));
      await tester.pump();
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Review split'),
            )
            .onPressed,
        isNotNull,
      );
      final shares = receiptAllocations(receipt, 'alice', people);
      expect(shares['alice']!.totalMinor, 56350);
      expect(shares['bob']!.totalMinor, 56350);
    },
  );

  testWidgets('review excludes deleted members and blocks mismatched totals', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.localMembers)
        .insert(
          LocalMembersCompanion.insert(
            id: 'alice',
            tripId: 'trip',
            displayName: 'Alice',
          ),
        );
    await db
        .into(db.localMembers)
        .insert(
          LocalMembersCompanion.insert(
            id: 'old',
            tripId: 'trip',
            displayName: 'Deleted account',
          ),
        );
    final receipt = photoReceipt();
    receipt.printedTotalMinor = 120000;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(
            TripRepository(db: db, userId: 'alice'),
          ),
        ],
        child: MaterialApp(home: LineItemReviewScreen(receipt: receipt)),
      ),
    );
    final next = find.text('Choose who shares each item');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.byType(ItemClaimScreen), findsNothing);
    expect(find.textContaining('Items and charges must match'), findsOneWidget);
    final printed = find.widgetWithText(
      TextFormField,
      'Printed bill total (INR)',
    );
    await tester.ensureVisible(printed);
    await tester.enterText(printed, '1127.00');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    final screen = tester.widget<ItemClaimScreen>(find.byType(ItemClaimScreen));
    expect(screen.members.map((m) => m.name), ['Alice']);
    expect(screen.receipt.taxMinor, 17190);
  });
}
