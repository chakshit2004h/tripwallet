import '../db/app_database.dart';

Map<String, int> calculateBalances(List<LocalMember> members,
    List<LocalExpense> expenses, List<LocalExpenseSplit> splits,
    List<LocalSettlement> settlements) {
  final balances = {for (final member in members) member.id: 0};
  for (final expense in expenses) {
    final shares = splits.where((s) => s.expenseId == expense.id).toList();
    if (shares.fold(0, (int sum, s) => sum + s.amountMinor) != expense.amountMinor) {
      throw StateError('This expense needs its split restored. Connect and sync before settling.');
    }
    balances[expense.paidByMemberId] =
        (balances[expense.paidByMemberId] ?? 0) + expense.amountMinor;
    for (final share in shares) {
      balances[share.memberId] = (balances[share.memberId] ?? 0) - share.amountMinor;
    }
  }
  for (final settlement in settlements.where((s) => s.status == 'confirmed')) {
    balances[settlement.fromMemberId] =
        (balances[settlement.fromMemberId] ?? 0) + settlement.amountMinor;
    balances[settlement.toMemberId] =
        (balances[settlement.toMemberId] ?? 0) - settlement.amountMinor;
  }
  return balances;
}
