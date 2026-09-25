import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/features/trip_dashboard/presentation/trip_summary_sheet.dart';
import 'package:tripwallet_client/features/paywall/presentation/paywall_modal.dart';

void main() {
  group('Trip Summary & Paywall Widget Tests', () {
    testWidgets('TripSummarySheet displays metrics, spenders, and export buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => TripSummarySheet.show(context),
                child: const Text('Open Summary'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Summary'));
      await tester.pumpAndSettle();

      expect(find.text('Goa Weekend 2026'), findsOneWidget);
      expect(find.text('₹34,250'), findsOneWidget);
      expect(find.textContaining('Rahul was the top spender'), findsOneWidget);
      expect(find.text('Export PDF'), findsOneWidget);
      expect(find.text('Export Excel CSV'), findsOneWidget);

      // Tap Export PDF
      await tester.ensureVisible(find.text('Export PDF'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export PDF'));
      await tester.pump();
      expect(find.text('Generated Goa_Trip_2026_Summary.pdf!'), findsOneWidget);
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
