class ClaimAllocation {
  final String memberId;
  final int subtotalMinor;
  final int taxMinor;
  final int serviceChargeMinor;
  final int totalMinor;
  final int adjustmentMinor;

  const ClaimAllocation({
    required this.memberId,
    required this.subtotalMinor,
    required this.taxMinor,
    required this.serviceChargeMinor,
    required this.totalMinor,
    this.adjustmentMinor = 0,
  });

  @override
  String toString() =>
      'ClaimAllocation(memberId: $memberId, subtotal: $subtotalMinor, tax: $taxMinor, service: $serviceChargeMinor, total: $totalMinor)';
}

/// Prorates tax and service charge across members based on claimed item subtotals.
/// Zero-cent rounding residue is deterministically assigned to the payer.
Map<String, ClaimAllocation> prorateReceipt({
  required String payerId,
  required Map<String, int> memberSubtotals,
  required int totalTaxMinor,
  required int totalServiceChargeMinor,
}) {
  final grandSubtotal = memberSubtotals.values.fold<int>(
    0,
    (sum, val) => sum + val,
  );
  if (totalTaxMinor < 0 ||
      totalServiceChargeMinor < 0 ||
      memberSubtotals.values.any((v) => v < 0)) {
    throw ArgumentError('Amounts cannot be negative');
  }
  final result = <String, ClaimAllocation>{};

  if (grandSubtotal <= 0) {
    return result;
  }

  var allocatedTax = 0;
  var allocatedService = 0;

  memberSubtotals.forEach((memberId, subtotal) {
    // Proportional calculation using BigInt-safe integer math
    final memberTax = (subtotal * totalTaxMinor) ~/ grandSubtotal;
    final memberService = (subtotal * totalServiceChargeMinor) ~/ grandSubtotal;

    allocatedTax += memberTax;
    allocatedService += memberService;

    result[memberId] = ClaimAllocation(
      memberId: memberId,
      subtotalMinor: subtotal,
      taxMinor: memberTax,
      serviceChargeMinor: memberService,
      totalMinor: subtotal + memberTax + memberService,
    );
  });

  // Assign residue due to integer truncation to the payer
  final residueTax = totalTaxMinor - allocatedTax;
  final residueService = totalServiceChargeMinor - allocatedService;

  result.putIfAbsent(
    payerId,
    () => ClaimAllocation(
      memberId: payerId,
      subtotalMinor: 0,
      taxMinor: 0,
      serviceChargeMinor: 0,
      totalMinor: 0,
    ),
  );
  if (result.containsKey(payerId)) {
    final prev = result[payerId]!;
    result[payerId] = ClaimAllocation(
      memberId: payerId,
      subtotalMinor: prev.subtotalMinor,
      taxMinor: prev.taxMinor + residueTax,
      serviceChargeMinor: prev.serviceChargeMinor + residueService,
      totalMinor: prev.totalMinor + residueTax + residueService,
    );
  }

  return result;
}
