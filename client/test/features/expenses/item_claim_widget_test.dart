import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/theme/app_theme.dart';
import 'package:tripwallet_client/features/expenses/domain/receipt_models.dart';
import 'package:tripwallet_client/features/expenses/presentation/item_claim_screen.dart';
import 'package:tripwallet_client/features/expenses/presentation/line_item_review_screen.dart';

void main() {
  group('Phase 3 UI Widget Tests', () {
    testWidgets('LineItemReviewScreen renders parsed items and title', (tester) async {
      final receipt = ReceiptData.getPresetSample('goa', 'trip-test-123');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: LineItemReviewScreen(receipt: receipt),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review Scanned Items'), findsOneWidget);
      expect(find.text('98% OCR Match'), findsOneWidget);
      expect(find.text('Continue to Item Claiming'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('ItemClaimScreen renders members and enables dish claiming', (tester) async {
      final receipt = ReceiptData.getPresetSample('goa', 'trip-test-123');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: ItemClaimScreen(receipt: receipt),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Claim Your Dishes'), findsOneWidget);
      expect(find.text('Review Split Details'), findsOneWidget);
      expect(find.text('SELECTING FOR:'), findsOneWidget);

      // Verify members exist
      expect(find.byType(ChoiceChip), findsWidgets);

      // Verify dishes rendered
      expect(find.text('Butter Chicken'), findsOneWidget);
      expect(find.text('Garlic Naan (x2)'), findsOneWidget);

      // Tap on Garlic Naan to toggle claim
      await tester.tap(find.text('Garlic Naan (x2)'));
      await tester.pumpAndSettle();

      // Verify bottom proration bar is displayed
      expect(find.text('Review Split Details'), findsOneWidget);
    });
  });
}
