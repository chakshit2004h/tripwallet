import '../db/app_database.dart';

/// Account deletion currently retains a member with this reserved server label
/// to preserve historical balances. It must not participate in new expenses.
bool canShareNewExpense(LocalMember member) =>
    member.displayName.trim().toLowerCase() != 'deleted account';
