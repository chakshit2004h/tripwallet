class DebtTransfer {
  final String fromMemberId;
  final String toMemberId;
  final int amountMinor;

  const DebtTransfer({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amountMinor,
  });

  @override
  String toString() => 'DebtTransfer($fromMemberId -> $toMemberId: $amountMinor)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtTransfer &&
          runtimeType == other.runtimeType &&
          fromMemberId == other.fromMemberId &&
          toMemberId == other.toMemberId &&
          amountMinor == other.amountMinor;

  @override
  int get hashCode => Object.hash(fromMemberId, toMemberId, amountMinor);
}

/// Greedy minimum cash flow algorithm to simplify pairwise debts into minimal transfers.
/// Net balances:
///   positive = member is owed money (creditor)
///   negative = member owes money (debtor)
List<DebtTransfer> simplifyDebts(Map<String, int> netBalances) {
  final debtors = <MapEntry<String, int>>[];
  final creditors = <MapEntry<String, int>>[];

  netBalances.forEach((member, balance) {
    if (balance < 0) {
      debtors.add(MapEntry(member, -balance));
    } else if (balance > 0) {
      creditors.add(MapEntry(member, balance));
    }
  });

  debtors.sort((a, b) => b.value.compareTo(a.value));
  creditors.sort((a, b) => b.value.compareTo(a.value));

  final transfers = <DebtTransfer>[];
  var debtorIdx = 0;
  var creditorIdx = 0;

  var currentDebtorRem = debtorIdx < debtors.length ? debtors[debtorIdx].value : 0;
  var currentCreditorRem = creditorIdx < creditors.length ? creditors[creditorIdx].value : 0;

  while (debtorIdx < debtors.length && creditorIdx < creditors.length) {
    final settledAmt = currentDebtorRem < currentCreditorRem ? currentDebtorRem : currentCreditorRem;

    if (settledAmt > 0) {
      transfers.add(DebtTransfer(
        fromMemberId: debtors[debtorIdx].key,
        toMemberId: creditors[creditorIdx].key,
        amountMinor: settledAmt,
      ));
    }

    currentDebtorRem -= settledAmt;
    currentCreditorRem -= settledAmt;

    if (currentDebtorRem == 0) {
      debtorIdx++;
      if (debtorIdx < debtors.length) {
        currentDebtorRem = debtors[debtorIdx].value;
      }
    }

    if (currentCreditorRem == 0) {
      creditorIdx++;
      if (creditorIdx < creditors.length) {
        currentCreditorRem = creditors[creditorIdx].value;
      }
    }
  }

  return transfers;
}
