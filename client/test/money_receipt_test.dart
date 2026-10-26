import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/domain/money.dart';
import 'package:tripwallet_client/features/expenses/domain/receipt_parser.dart';

void main() {
  test('decimal amounts do not silently round or lose cents', () {
    expect(parseMinor('1234.05', 'INR'), 123405);
    expect(formatMoney(123405, 'INR'), '₹1234.05');
    expect(parseMinor('200', 'JPY'), 200);
    expect(() => parseMinor('1.999', 'INR'), throwsFormatException);
    expect(() => parseMinor('1.5', 'JPY'), throwsFormatException);
  });

  test('equal and weighted splits preserve every minor unit', () {
    for (var amount = 0; amount < 1000; amount++) {
      for (var people = 1; people <= 9; people++) {
        final ids = [for (var i = 0; i < people; i++) 'member-$i'];
        final equal = splitEqually(amount, ids);
        expect(equal.values.reduce((a, b) => a + b), amount);
        expect(equal.values.reduce((a, b) => a > b ? a : b) -
            equal.values.reduce((a, b) => a < b ? a : b), lessThanOrEqualTo(1));
        final weighted = splitByWeights(amount, {
          for (var i = 0; i < people; i++) ids[i]: i + 1,
        });
        expect(weighted.values.reduce((a, b) => a + b), amount);
      }
    }
    expect(() => splitByWeights(-1, {'a': 1}), throwsArgumentError);
  });

  test('receipt parser extracts charges without treating totals as items', () {
    final receipt = parseReceiptText('Cafe Vista\nCoffee 150.00\nToast 99.50\nGST 12.50\nTOTAL 262.00',
        tripId: 'trip', currency: 'INR', payerMemberId: 'member');
    expect(receipt.title, 'Cafe Vista');
    expect(receipt.items.map((item) => item.label), ['Coffee', 'Toast']);
    expect(receipt.taxMinor, 1250);
    expect(receipt.totalMinor, 26200);
  });
}
