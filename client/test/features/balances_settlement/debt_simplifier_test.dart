import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/domain/debt_simplifier.dart';

void main() {
  group('DebtSimplifier (Dart)', () {
    test('circular debts simplified to minimal transfers', () {
      // Net balances: A owes 1000 (-1000), B is even (0), C is owed 1000 (+1000)
      final balances = {
        'A': -1000,
        'B': 0,
        'C': 1000,
      };

      final transfers = simplifyDebts(balances);
      expect(transfers.length, equals(1));
      expect(transfers[0].fromMemberId, equals('A'));
      expect(transfers[0].toMemberId, equals('C'));
      expect(transfers[0].amountMinor, equals(1000));
    });

    test('multi-member debt simplification preserves conservation of money', () {
      // Amit owes 850 (-850), Rahul owes 600 (-600), Priya is owed 1200 (+1200), You are owed 250 (+250)
      final balances = {
        'Amit': -85000,
        'Rahul': -60000,
        'Priya': 120000,
        'You': 25000,
      };

      final transfers = simplifyDebts(balances);
      final totalTransferred = transfers.fold<int>(0, (sum, t) => sum + t.amountMinor);
      expect(totalTransferred, equals(85000 + 60000)); // Total owed
    });

    test('all zero balances produce zero transfers', () {
      final balances = {
        'A': 0,
        'B': 0,
        'C': 0,
      };

      final transfers = simplifyDebts(balances);
      expect(transfers, isEmpty);
    });
  });
}
