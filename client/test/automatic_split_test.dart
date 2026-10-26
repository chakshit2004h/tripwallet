import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/domain/money.dart';

void main() {
  test('entered shares stay fixed while the remainder is shared equally', () {
    const ids = ['p1', 'p2', 'p3'];
    expect(splitWithFixedShares(100000, ids, {'p1': 40000}), {
      'p1': 40000,
      'p2': 30000,
      'p3': 30000,
    });
    expect(splitWithFixedShares(100000, ids, {'p1': 40000, 'p2': 25000}), {
      'p1': 40000,
      'p2': 25000,
      'p3': 35000,
    });
    expect(splitWithFixedShares(120000, ids, {'p1': 40000, 'p2': 25000}), {
      'p1': 40000,
      'p2': 25000,
      'p3': 55000,
    });
  });
  test(
    'rounding, zero shares and a single person preserve the full amount',
    () {
      expect(splitWithFixedShares(100, ['c', 'b', 'a'], {}), {
        'a': 34,
        'b': 33,
        'c': 33,
      });
      expect(splitWithFixedShares(1, ['c', 'b', 'a'], {'a': 0}), {
        'a': 0,
        'b': 1,
        'c': 0,
      });
      expect(splitWithFixedShares(100, ['a', 'b'], {'a': 100}), {
        'a': 100,
        'b': 0,
      });
      expect(splitWithFixedShares(123, ['a'], {}), {'a': 123});
      expect(splitWithFixedShares(100, ['a', 'b'], {'a': 40, 'b': 60}), {
        'a': 40,
        'b': 60,
      });
    },
  );
  test('invalid totals cannot become saved splits', () {
    expect(
      () => splitWithFixedShares(100, ['a', 'b'], {'a': 101}),
      throwsFormatException,
    );
    expect(
      () => splitWithFixedShares(100, ['a', 'b'], {'a': 40, 'b': 50}),
      throwsFormatException,
    );
    expect(() => splitWithFixedShares(100, [], {}), throwsFormatException);
    expect(
      () => splitWithFixedShares(100, ['a'], {'a': -1}),
      throwsArgumentError,
    );
  });
}
