import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripwallet_client/app.dart';

void main() {
  testWidgets('TripWallet app boots with splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TripWalletApp(),
      ),
    );

    // Verify RichText containing TripWallet wordmark
    final richTextFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('TripWallet'),
    );

    expect(richTextFinder, findsOneWidget);

    // Advance timer to avoid pending timers
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
