import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/theme/app_theme.dart';
import 'package:tripwallet_client/features/balances_settlement/presentation/settle_sheet.dart';
import 'package:tripwallet_client/features/balances_settlement/presentation/settlement_confirm_dialog.dart';

void main() {
  group('Balances and settlement', () {
    testWidgets('SettleSheet displays payee, amount, and payment methods', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    SettleSheet.show(
                      context,
                      tripId: 'test-trip-1',
                      fromMemberId: 'm1',
                      toMemberId: 'm4',
                      payeeName: 'Amit',
                      amountMinor: 85000,
                    );
                  },
                  child: const Text('Open Settle'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Settle'));
      await tester.pumpAndSettle();

      expect(find.text('Settle with Amit'), findsOneWidget);
      expect(find.text('₹850.00'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('Record cash you have handed over.'), findsOneWidget);
    });

    testWidgets('SettlementConfirmDialog displays confirmation prompt', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SettlementConfirmDialog(
                tripId: 'test-trip-1',
                fromMemberId: 'm1',
                toMemberId: 'm4',
                payeeName: 'Amit',
                amountMinor: 85000,
                method: 'Google Pay',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Record this payment?'), findsOneWidget);
      expect(find.text('Not yet'), findsOneWidget);
      expect(find.text('Yes, record payment'), findsOneWidget);
    });
  });
}
