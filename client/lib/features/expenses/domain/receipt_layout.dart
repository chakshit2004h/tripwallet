import 'dart:math' as math;

/// A recognized text fragment in image coordinates.
class ReceiptTextFragment {
  final String text;
  final double left, top, right, bottom;

  const ReceiptTextFragment({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get centerY => (top + bottom) / 2;
  double get height => bottom - top;
}

/// OCR may return the description and price columns as separate blocks.
/// Reconstruct rows from their positions instead of trusting block order.
String receiptTextInReadingOrder(Iterable<ReceiptTextFragment> fragments) {
  final sorted =
      fragments.where((f) => f.text.trim().isNotEmpty && f.height > 0).toList()
        ..sort((a, b) {
          final vertical = a.centerY.compareTo(b.centerY);
          return vertical == 0 ? a.left.compareTo(b.left) : vertical;
        });
  final rows = <List<ReceiptTextFragment>>[];
  for (final fragment in sorted) {
    List<ReceiptTextFragment>? match;
    var closest = double.infinity;
    for (final row in rows) {
      final anchor = row.first;
      final distance = (anchor.centerY - fragment.centerY).abs();
      final tolerance = math.min(anchor.height, fragment.height) * 0.5;
      final overlaps = row.any(
        (other) => fragment.left < other.right && fragment.right > other.left,
      );
      if (!overlaps && distance <= tolerance && distance < closest) {
        match = row;
        closest = distance;
      }
    }
    if (match == null) {
      rows.add([fragment]);
    } else {
      match.add(fragment);
    }
  }
  return rows
      .map((row) {
        row.sort((a, b) => a.left.compareTo(b.left));
        return row.map((f) => f.text.trim()).join(' ');
      })
      .join('\n');
}
