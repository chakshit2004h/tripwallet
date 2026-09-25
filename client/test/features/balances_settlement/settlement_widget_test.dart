import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/theme/app_theme.dart';
import 'package:tripwallet_client/features/balances_settlement/presentation/settle_sheet.dart';
import 'package:tripwallet_client/features/balances_settlement/presentation/settlement_confirm_dialog.dart';

void main() {
  group('Phase 4 Balances & Settlement Widget Tests', () {
    testWidgets('SettleSheet displays payee, amount, and payment methods', (tester) async {
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

      expect(find.text('Settle Up'), findsOneWidget);
      expect(find.text('Paying Amit'), findsOneWidget);
      expect(find.text('₹850.00'), findsOneWidget);
      expect(find.text('Google Pay'), findsOneWidget);
      expect(find.text('PhonePe'), findsOneWidget);
      expect(find.text('Cash / Settled Directly'), findsOneWidget);
    });

    testWidgets('SettlementConfirmDialog displays confirmation prompt', (tester) async {
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

      expect(find.text('Did the payment go through?'), findsOneWidget);
      expect(find.text('Not yet'), findsOneWidget);
      expect(find.text('Yes, settled'), findsOneWidget);
    });
  });
}
