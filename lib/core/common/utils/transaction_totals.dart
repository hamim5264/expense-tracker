import 'package:expense_tracker/features/expense/domain/entities/expense.dart';

/// Shared accounting rules for user income and spending summaries.
/// Wallet-to-wallet transfers affect individual wallet balances, but are not
/// new income or spending for the user as a whole.
class TransactionTotals {
  static bool isInternalTransfer(Expense transaction) {
    return transaction.category.trim().toLowerCase() == 'transfer' ||
        transaction.title.trim().toLowerCase().startsWith('transfer ');
  }

  static double income(Iterable<Expense> transactions) => transactions
      .where((tx) => tx.type.toLowerCase() == 'income' && !isInternalTransfer(tx))
      .fold(0, (sum, tx) => sum + tx.amount);

  static double expenses(Iterable<Expense> transactions) => transactions
      .where((tx) => tx.type.toLowerCase() == 'expense' && !isInternalTransfer(tx))
      .fold(0, (sum, tx) => sum + tx.amount);

  static List<Expense> externalTransactions(Iterable<Expense> transactions) =>
      transactions.where((tx) => !isInternalTransfer(tx)).toList();
}
