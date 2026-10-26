import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/features/expenses/data/receipt_text_recognizer.dart';
import 'package:tripwallet_client/features/expenses/domain/receipt_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(ReceiptTextRecognizer.channel, null);
  });

  test(
    'Android PaddleOCR boxes flow into receipt parsing in reading order',
    () async {
      messenger.setMockMethodCallHandler(ReceiptTextRecognizer.channel, (
        call,
      ) async {
        expect(call.method, 'recognize');
        expect(call.arguments, {'path': '/receipt.jpg'});
        return [
          {'text': 'Cafe', 'left': 0, 'top': 0, 'right': 90, 'bottom': 20},
          {'text': 'Coffee', 'left': 0, 'top': 40, 'right': 90, 'bottom': 60},
          {'text': 'TOTAL', 'left': 0, 'top': 70, 'right': 90, 'bottom': 90},
          {'text': '150', 'left': 200, 'top': 72, 'right': 260, 'bottom': 92},
          {'text': '150', 'left': 200, 'top': 42, 'right': 260, 'bottom': 62},
        ];
      });
      final text = await ReceiptTextRecognizer().recognize('/receipt.jpg');
      final receipt = parseReceiptText(
        text,
        tripId: 'trip',
        currency: 'INR',
        payerMemberId: 'payer',
      );
      expect(receipt.items.single.label, 'Coffee');
      expect(receipt.totalMinor, 15000);
    },
  );

  test(
    'empty recognition remains empty instead of fabricating items',
    () async {
      messenger.setMockMethodCallHandler(
        ReceiptTextRecognizer.channel,
        (_) async => [],
      );
      expect(await ReceiptTextRecognizer().recognize('/blank.jpg'), isEmpty);
    },
  );

  test('native failures propagate to the scan screen', () async {
    messenger.setMockMethodCallHandler(ReceiptTextRecognizer.channel, (
      _,
    ) async {
      throw PlatformException(code: 'ocr_failed');
    });
    await expectLater(
      ReceiptTextRecognizer().recognize('/broken.jpg'),
      throwsA(isA<PlatformException>()),
    );
  });
}
