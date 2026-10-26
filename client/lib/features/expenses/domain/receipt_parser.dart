import '../../../core/domain/money.dart';
import 'receipt_models.dart';

/// Conservative text parser: every result is reviewed before being saved.
ReceiptData parseReceiptText(
  String text, {
  required String tripId,
  required String currency,
  required String payerMemberId,
}) {
  final items = <ReceiptItem>[];
  var tax = 0;
  var service = 0;
  final taxes = <String, int>{};
  int? printedTotal;
  var hasGrandTotal = false;
  var hasTaxColumn = false;
  final lines = text
      .split(RegExp(r'[\r\n]+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  // The last column is the line total, not the quantity or unit price.
  final number = currencyDigits(currency) == 0
      ? r'\d[\d,]*'
      : r'\d[\d,]*(?:\.\d{1,2})?';
  final amountPattern = RegExp(
    r'^(.+?)\s+(?:(?:INR|USD|EUR|GBP|JPY|Rs\.?|[₹$€£¥])\s*)?(' +
        number +
        r')(?:\s*(?:INR|USD|EUR|GBP|JPY|/-))?\s*$',
    caseSensitive: false,
  );
  for (final line in lines) {
    if (RegExp(r'\b(qty|quantity)\b', caseSensitive: false).hasMatch(line) &&
        RegExp(r'\b(rate|price)\b', caseSensitive: false).hasMatch(line)) {
      hasTaxColumn = RegExp(r'\btax', caseSensitive: false).hasMatch(line);
      continue;
    }
    final match = amountPattern.firstMatch(line);
    if (match == null) continue;
    var label = match.group(1)!.trim();
    final lower = label.toLowerCase();
    if (!RegExp(r'[a-zA-Z]').hasMatch(label)) continue;
    // Whole-number prices are common, but receipt metadata also ends in digits.
    if (RegExp(
      r'^(?:(?:invoice|bill|receipt|order|table|token|phone|tel|mobile|date|time|gstin|tin|fssai|zip|pin|qty|quantity|items|guests|pax)\b|(?:no|number)\s*[:.#])',
    ).hasMatch(lower)) {
      continue;
    }
    // Never turn a negative adjustment into a positive item.
    if (RegExp(r'[-−]\s*$').hasMatch(label)) continue;
    int price;
    try {
      price = parseMinor(match.group(2)!.replaceAll(',', ''), currency);
    } on FormatException {
      continue;
    }
    if (RegExp(
          r'\b(grand\s*total|total|amount\s*due|net\s*amount)\b',
        ).hasMatch(lower) &&
        !RegExp(
          r'\b(subtotal|sub total|tax|gst|cgst|sgst|vat)\b',
        ).hasMatch(lower)) {
      final grand = RegExp(r'grand\s*total').hasMatch(lower);
      if (grand || !hasGrandTotal) printedTotal = price;
      hasGrandTotal = hasGrandTotal || grand;
      continue;
    }
    if (RegExp(
      r'\b(total|subtotal|sub total|balance|change|cash|tender|discount|payment|paid|savings)\b',
    ).hasMatch(lower)) {
      continue;
    }
    if (RegExp(
      r'^(?:r[.\s]*[o0][.\s]*(?:\(|$)|round(?:ing)?\b)',
    ).hasMatch(lower)) {
      items.add(
        ReceiptItem(
          label: 'Round-off',
          priceMinor: price,
          isAdjustment: true,
          confidence: 0,
        ),
      );
      continue;
    }
    final taxMatch = RegExp(
      r'\b(cgst|sgst|igst|gst|vat|tax)\b',
    ).firstMatch(lower);
    if (taxMatch != null) {
      final name = taxMatch.group(1)!.toUpperCase();
      taxes[name] = (taxes[name] ?? 0) + price;
      tax += price;
      continue;
    }
    if (RegExp(r'\b(service|tip|gratuity)\b').hasMatch(lower)) {
      service += price;
      continue;
    }
    var quantity = 1;
    int? unitPrice;
    String? taxRate;
    // Separate the receipt's numeric columns from its description. Without a
    // header, only strip a quantity/rate pair when it explains the line total.
    final columns = RegExp(
      hasTaxColumn
          ? r'^(.+?)\s+(\d+)\s+([\d,]+(?:\.\d{1,2})?)\s+(\d+(?:\.\d+)?)[%]?$'
          : r'^(.+?)\s+(\d+)\s+([\d,]+(?:\.\d{1,2})?)$',
    ).firstMatch(label);
    if (columns != null) {
      try {
        final qty = int.parse(columns.group(2)!);
        final rate = parseMinor(
          columns.group(3)!.replaceAll(',', ''),
          currency,
        );
        if (qty > 0 && (hasTaxColumn || qty * rate == price)) {
          label = columns.group(1)!.trim();
          quantity = qty;
          unitPrice = rate;
          if (hasTaxColumn) taxRate = columns.group(4);
        }
      } on FormatException {
        /* Preserve uncertain text for manual review. */
      }
    }
    items.add(
      ReceiptItem(
        label: label,
        priceMinor: price,
        quantity: quantity,
        unitPriceMinor: unitPrice,
        taxRatePercent: taxRate,
        confidence: 0,
      ),
    );
  }
  final titles = lines.where(
    (line) => !RegExp(
      r'^(tax\s+)?invoice$|^receipt$',
      caseSensitive: false,
    ).hasMatch(line),
  );
  final title = titles.firstOrNull ?? 'Receipt';
  return ReceiptData(
    tripId: tripId,
    currency: currency,
    title: title.substring(0, title.length.clamp(0, 120)),
    payerMemberId: payerMemberId,
    items: items,
    taxMinor: tax,
    taxBreakdown: taxes,
    printedTotalMinor: printedTotal,
    serviceChargeMinor: service,
  );
}
