const supportedCurrencies = ['INR', 'USD', 'EUR', 'GBP', 'JPY'];

int currencyDigits(String currency) => currency == 'JPY' ? 0 : 2;

String currencySymbol(String currency) =>
    const {
      'INR': '₹',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
    }[currency] ??
    '$currency ';

/// Parse decimal input without a floating point conversion or silent rounding.
int parseMinor(String input, String currency, {bool allowZero = false}) {
  final digits = currencyDigits(currency);
  final value = input.trim();
  final pattern = digits == 0 ? r'^\d+$' : r'^\d+(?:\.\d{1,2})?$';
  if (!RegExp(pattern).hasMatch(value)) {
    throw FormatException(
      digits == 0
          ? 'Enter a whole number for $currency.'
          : 'Enter an amount with at most two decimal places.',
    );
  }
  final parts = value.split('.');
  final minor =
      int.parse(parts[0]) * (digits == 0 ? 1 : 100) +
      (parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0);
  if (minor < (allowZero ? 0 : 1) || minor > 100000000000) {
    throw const FormatException('Enter a valid positive amount.');
  }
  return minor;
}

String decimalAmount(int minor, String currency) {
  final absolute = minor.abs();
  final sign = minor < 0 ? '-' : '';
  if (currencyDigits(currency) == 0) return '$sign$absolute';
  return '$sign${absolute ~/ 100}.${(absolute % 100).toString().padLeft(2, '0')}';
}

String formatMoney(int minor, String currency) =>
    '${minor < 0 ? '-' : ''}${currencySymbol(currency)}${decimalAmount(minor.abs(), currency)}';

/// Stable ordering makes retries and independent devices allocate the same cents.
Map<String, int> splitEqually(int amount, Iterable<String> participants) {
  final ids = participants.toSet().toList()..sort();
  if (ids.isEmpty || amount < 0) throw ArgumentError('Invalid split');
  return {
    for (var i = 0; i < ids.length; i++)
      ids[i]: amount ~/ ids.length + (i < amount % ids.length ? 1 : 0),
  };
}

Map<String, int> splitByWeights(int amount, Map<String, int> weights) {
  if (amount < 0 || weights.isEmpty || weights.values.any((w) => w < 0)) {
    throw ArgumentError('Invalid weights');
  }
  final total = weights.values.fold(0, (a, b) => a + b);
  if (total <= 0) throw ArgumentError('Select at least one participant');
  final result = {
    for (final e in weights.entries) e.key: amount * e.value ~/ total,
  };
  final ids = weights.keys.toList()
    ..sort((a, b) {
      final remainder = (amount * weights[b]! % total).compareTo(
        amount * weights[a]! % total,
      );
      return remainder == 0 ? a.compareTo(b) : remainder;
    });
  final residue = amount - result.values.fold(0, (a, b) => a + b);
  for (var i = 0; i < residue; i++) {
    result[ids[i]] = result[ids[i]]! + 1;
  }
  return result;
}

/// Keep entered shares fixed and divide the remainder in whole minor units.
Map<String, int> splitWithFixedShares(
  int amount,
  Iterable<String> participants,
  Map<String, int> fixedShares,
) {
  final ids = participants.toSet();
  if (ids.isEmpty) {
    throw const FormatException('Choose at least one person to split with.');
  }
  if (amount < 0 ||
      fixedShares.values.any((share) => share < 0) ||
      fixedShares.keys.any((id) => !ids.contains(id))) {
    throw ArgumentError('Invalid fixed shares');
  }
  final remainder =
      amount - fixedShares.values.fold<int>(0, (sum, share) => sum + share);
  if (remainder < 0) {
    throw const FormatException(
      'The shares you entered exceed the expense amount.',
    );
  }
  final automatic = ids.where((id) => !fixedShares.containsKey(id)).toList();
  if (automatic.isEmpty) {
    if (remainder != 0) {
      throw const FormatException(
        'Shares must add up to the expense amount. Clear a share to calculate it automatically.',
      );
    }
    return Map.of(fixedShares);
  }
  return {...fixedShares, ...splitEqually(remainder, automatic)};
}
