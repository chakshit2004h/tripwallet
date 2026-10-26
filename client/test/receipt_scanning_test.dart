import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/features/expenses/domain/receipt_layout.dart';
import 'package:tripwallet_client/features/expenses/domain/receipt_parser.dart';

void main() {
  test('reads whole and fractional prices with currency markers', () {
    final receipt = parseReceiptText(
      'Cafe\nCoffee 150\nToast Rs. 99.5\nTea ₹40\nCake 60 INR\nWater 20/-\nGST 18.48\nTOTAL 387.98',
      tripId: 'trip',
      currency: 'INR',
      payerMemberId: 'payer',
    );
    expect(receipt.items.map((i) => i.priceMinor), [
      15000,
      9950,
      4000,
      6000,
      2000,
    ]);
    expect(receipt.taxMinor, 1848);
    expect(receipt.totalMinor, 38798);
  });

  test('does not turn metadata, totals or adjustments into items', () {
    final receipt = parseReceiptText(
      'Cafe\nBill No: 123\nTable 4\nPhone 9876543210\nGSTIN 12345\nQty 2\n'
      'Coffee 2 75.00 150.00\nDiscount - 10.00\nCoupon -10.00\n'
      'Subtotal 150.00\nCash 200\nChange 50\nTotal 150',
      tripId: 'trip',
      currency: 'INR',
      payerMemberId: 'payer',
    );
    expect(receipt.items, hasLength(1));
    expect(receipt.items.single.priceMinor, 15000);
  });

  test('reassembles separate OCR columns before parsing', () {
    const fragments = [
      ReceiptTextFragment(text: 'Cafe', left: 0, top: 0, right: 90, bottom: 20),
      ReceiptTextFragment(
        text: 'Coffee',
        left: 0,
        top: 40,
        right: 90,
        bottom: 60,
      ),
      ReceiptTextFragment(
        text: 'Toast',
        left: 0,
        top: 70,
        right: 90,
        bottom: 90,
      ),
      ReceiptTextFragment(
        text: 'TOTAL',
        left: 0,
        top: 100,
        right: 90,
        bottom: 120,
      ),
      ReceiptTextFragment(
        text: '249.50',
        left: 200,
        top: 102,
        right: 260,
        bottom: 122,
      ),
      ReceiptTextFragment(
        text: '99.50',
        left: 200,
        top: 72,
        right: 260,
        bottom: 92,
      ),
      ReceiptTextFragment(
        text: '150',
        left: 200,
        top: 42,
        right: 260,
        bottom: 62,
      ),
    ];
    final text = receiptTextInReadingOrder(fragments);
    expect(text, 'Cafe\nCoffee 150\nToast 99.50\nTOTAL 249.50');
    final receipt = parseReceiptText(
      text,
      tripId: 'trip',
      currency: 'INR',
      payerMemberId: 'payer',
    );
    expect(receipt.items.map((i) => i.label), ['Coffee', 'Toast']);
    expect(receipt.totalMinor, 24950);
  });

  test('supports grouped prices and whole yen amounts', () {
    final receipt = parseReceiptText(
      'Cafe\nMeal ¥1,200\nTax 120\nTotal 1,320',
      tripId: 'trip',
      currency: 'JPY',
      payerMemberId: 'payer',
    );
    expect(receipt.items.single.priceMinor, 1200);
    expect(receipt.totalMinor, 1320);
  });
}
