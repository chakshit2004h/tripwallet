import 'package:flutter/material.dart';
import '../../../core/domain/money.dart';
import '../domain/receipt_models.dart';

class ReceiptTotals extends StatelessWidget {
  final ReceiptData receipt;
  const ReceiptTotals({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    Widget row(String label, int value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
            ),
          ),
          Text(
            formatMoney(value, receipt.currency),
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
        ],
      ),
    );
    final breakdownMatches =
        receipt.taxBreakdown.values.fold(0, (a, b) => a + b) ==
        receipt.taxMinor;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row('Items subtotal', receipt.subtotalMinor),
            if (breakdownMatches)
              ...receipt.taxBreakdown.entries.map((e) => row(e.key, e.value)),
            row('Total tax', receipt.taxMinor),
            if (receipt.serviceChargeMinor != 0)
              row('Service charge / tip', receipt.serviceChargeMinor),
            if (receipt.adjustmentMinor != 0)
              row('Round-off', receipt.adjustmentMinor),
            const Divider(),
            row('Bill total', receipt.totalMinor, bold: true),
            if (receipt.printedTotalMinor != null &&
                receipt.printedTotalMinor != receipt.totalMinor)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'The printed total is ${formatMoney(receipt.printedTotalMinor!, receipt.currency)}. Check missed items, discounts, and charges before continuing.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
