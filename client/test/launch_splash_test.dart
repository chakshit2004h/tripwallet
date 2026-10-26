import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/widgets/launch_splash.dart';

void main() {
  for (final destination in ['Your trips', 'Welcome', 'Trip invite']) {
    testWidgets('launch splash precedes $destination and does not replay', (
      tester,
    ) async {
      Widget app(String page) => MaterialApp(
        home: LaunchSplash(child: Scaffold(body: Text(page))),
      );
      await tester.pumpWidget(app(destination));
      expect(find.text('TripWallet'), findsOneWidget);
      expect(find.text(destination), findsNothing);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('TripWallet'), findsNothing);
      expect(find.text(destination), findsOneWidget);
      await tester.pumpWidget(app('Another page'));
      expect(find.text('Another page'), findsOneWidget);
      expect(find.text('TripWallet'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(app(destination));
      expect(find.text('TripWallet'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1200));
    });
  }
  testWidgets('closing during splash cancels its timer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LaunchSplash(child: Text('Home'))),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
