import 'package:flutter_test/flutter_test.dart';
import 'package:tripwallet_client/core/domain/proration_engine.dart';

void main() {
  group('ProrationEngine', () {
    test('exact proration with residue assigned to payer', () {
      const payer = 'user-payer';
      const friend = 'user-friend';

      final subtotals = {
        payer: 1000, // 10.00
        friend: 2000, // 20.00
      };
      // Grand subtotal = 3000
      // Tax: 250 -> 1/3 (83), 2/3 (166). Residue: 250 - 249 = 1 to payer.
      // Service: 150 -> 1/3 (50), 2/3 (100). Residue: 0.

      final allocations = prorateReceipt(
        payerId: payer,
        memberSubtotals: subtotals,
        totalTaxMinor: 250,
        totalServiceChargeMinor: 150,
      );

      expect(allocations[payer]?.taxMinor, equals(84));
      expect(allocations[friend]?.taxMinor, equals(166));
      expect(allocations[payer]?.serviceChargeMinor, equals(50));
      expect(allocations[friend]?.serviceChargeMinor, equals(100));

      // Invariance check: sum of totals must equal subtotal + tax + service
      final totalSum = allocations.values.fold<int>(0, (sum, a) => sum + a.totalMinor);
      expect(totalSum, equals(3000 + 250 + 150));
    });

    test('multi-member proration invariance', () {
      const payer = 'alice';
      final subtotals = {
        'alice': 1540,
        'bob': 2250,
        'charlie': 980,
        'diana': 3410,
      };
      const tax = 780;
      const service = 1200;

      final allocations = prorateReceipt(
        payerId: payer,
        memberSubtotals: subtotals,
        totalTaxMinor: tax,
        totalServiceChargeMinor: service,
      );

      final totalSum = allocations.values.fold<int>(0, (sum, a) => sum + a.totalMinor);
      final expectedGrandTotal = subtotals.values.fold<int>(0, (s, v) => s + v) + tax + service;
      expect(totalSum, equals(expectedGrandTotal));
    });
  });
}
