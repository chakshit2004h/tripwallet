import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripwallet_client/core/payment/payment_launcher.dart';
import 'package:tripwallet_client/core/theme/app_theme.dart';
import 'package:tripwallet_client/features/balances_settlement/presentation/settle_sheet.dart';
import 'package:tripwallet_client/features/balances_settlement/presentation/payment_handoff_screen.dart';

void main() {
  const channel = MethodChannel('tripwallet/payments');
  final calls = <MethodCall>[];
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test(
    'payment encodes names and rejects injected recipient and invalid amount',
    () {
      final uri = Uri.parse(
        PaymentLauncher.buildUpiUri(
          payeeVpa: 'rahul@bank',
          payeeName: 'Rahul & am=1',
          amountMinor: 45001,
        ),
      );
      expect(uri.queryParameters['pa'], 'rahul@bank');
      expect(uri.queryParameters['am'], '450.01');
      expect(uri.queryParameters['pn'], 'Rahul & am=1');
      expect(
        () => PaymentLauncher.buildUpiUri(
          payeeVpa: 'rahul@bank&pa=other@bank',
          payeeName: 'Rahul',
          amountMinor: 1,
        ),
        throwsFormatException,
      );
      expect(
        () => PaymentLauncher.buildUpiUri(
          payeeVpa: 'rahul@bank',
          payeeName: 'Rahul',
          amountMinor: 0,
        ),
        throwsFormatException,
      );
    },
  );

  testWidgets(
    'review validates recipient; selected app opens only after Pay; never auto records',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SettleSheet(
                tripId: 'trip',
                tripName: 'Goa weekend',
                fromMemberId: 'payer',
                toMemberId: 'recipient',
                payeeName: 'Rahul',
                amountMinor: 45000,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Online'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Review payment'));
      await tester.tap(find.text('Review payment'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Enter a valid recipient'), findsOneWidget);
      expect(calls, isEmpty);
      await tester.enterText(find.byType(TextFormField), 'rahul@bank');
      await tester.ensureVisible(find.text('PhonePe'));
      await tester.tap(find.text('PhonePe'));
      await tester.ensureVisible(find.text('Review payment'));
      await tester.tap(find.text('Review payment'));
      await tester.pumpAndSettle();
      expect(find.text('Pay Rahul'), findsOneWidget);
      expect(find.text('Goa weekend'), findsOneWidget);
      expect(calls, isEmpty);
      await tester.ensureVisible(find.text('Pay with PhonePe'));
      await tester.tap(find.text('Pay with PhonePe'));
      await tester.pumpAndSettle();
      expect(calls, hasLength(1));
      expect(calls.single.arguments['package'], 'com.phonepe.app');
      expect(
        Uri.parse(
          calls.single.arguments['uri'] as String,
        ).queryParameters['am'],
        '450.00',
      );
      expect(find.text('Payment app opened · Not confirmed'), findsOneWidget);
      expect(find.text('Record this payment?'), findsNothing);
      await tester.ensureVisible(find.text('I have paid'));
      await tester.tap(find.text('I have paid'));
      await tester.pumpAndSettle();
      expect(find.text('Record this payment?'), findsOneWidget);
      await tester.tap(find.text('Not yet'));
      await tester.pumpAndSettle();
      expect(find.text('Record this payment?'), findsNothing);
      expect(find.byType(PaymentHandoffScreen), findsOneWidget);
    },
  );

  testWidgets(
    'missing payment app leaves manual copy and confirmation available',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (_) async => throw PlatformException(code: 'missing'),
          );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PaymentHandoffScreen(
            tripId: 'trip',
            fromMemberId: 'payer',
            toMemberId: 'recipient',
            payeeName: 'Rahul',
            amountMinor: 45000,
            paymentMethod: 'upi',
            launchUri: PaymentLauncher.buildUpiUri(
              payeeVpa: 'rahul@bank',
              payeeName: 'Rahul',
              amountMinor: 45000,
            ),
          ),
        ),
      );
      await tester.ensureVisible(find.text('Pay with Google Pay'));
      await tester.tap(find.text('Pay with Google Pay'));
      await tester.pumpAndSettle();
      expect(find.textContaining('could not be opened'), findsOneWidget);
      expect(find.text('Copy UPI ID'), findsOneWidget);
      expect(
        find
            .widgetWithText(OutlinedButton, 'I have paid')
            .evaluate()
            .single
            .widget,
        isA<OutlinedButton>().having(
          (button) => button.onPressed,
          'manual confirmation',
          isNotNull,
        ),
      );
      expect(find.text('Record this payment?'), findsNothing);
    },
  );

  testWidgets('non INR online payments do not offer UPI', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: SettleSheet(
            tripId: 'trip',
            fromMemberId: 'payer',
            toMemberId: 'recipient',
            payeeName: 'Rahul',
            amountMinor: 1000,
            currency: 'USD',
          ),
        ),
      ),
    );
    await tester.tap(find.text('Online'));
    await tester.pumpAndSettle();
    expect(find.text('Google Pay'), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.textContaining('Pay your friend in USD'), findsOneWidget);
    expect(calls, isEmpty);
  });
}
