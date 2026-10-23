import '../data/database.dart';

class AccountBalance {
  const AccountBalance({required this.account, required this.balanceCents});

  final Account account;
  final int balanceCents;
}

/// Calculates each account's live balance from its opening balance, money in,
/// money out, and transfers. A transfer is not income or spending: it only
/// moves value between two accounts.
List<AccountBalance> computeAccountBalances({
  required List<Account> accounts,
  required List<Withdrawal> withdrawals,
  required List<Spend> spends,
  required List<Transfer> transfers,
}) {
  if (accounts.isEmpty) return const [];

  final defaultId = accounts.first.id;
  final balances = <int, int>{
    for (final account in accounts) account.id: account.openingBalanceCents,
  };

  for (final withdrawal in withdrawals) {
    final id = withdrawal.accountId ?? defaultId;
    balances[id] = (balances[id] ?? 0) + withdrawal.amountCents;
  }
  for (final spend in spends) {
    final id = spend.accountId ?? defaultId;
    balances[id] = (balances[id] ?? 0) - spend.amountCents;
  }
  for (final transfer in transfers) {
    balances[transfer.fromAccountId] =
        (balances[transfer.fromAccountId] ?? 0) - transfer.amountCents;
    balances[transfer.toAccountId] =
        (balances[transfer.toAccountId] ?? 0) + transfer.amountCents;
  }

  return [
    for (final account in accounts)
      AccountBalance(
        account: account,
        balanceCents: balances[account.id] ?? account.openingBalanceCents,
      ),
  ];
}
