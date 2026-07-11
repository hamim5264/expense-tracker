part of 'expense_bloc.dart';

@immutable
sealed class ExpenseEvent {}

final class ExpenseFetchAll extends ExpenseEvent {}

final class ExpenseAddTransaction extends ExpenseEvent {
  final Expense expense;

  ExpenseAddTransaction(this.expense);
}

final class ExpenseAddWalletCard extends ExpenseEvent {
  final Wallet wallet;

  ExpenseAddWalletCard(this.wallet);
}

final class ExpenseDeleteWallet extends ExpenseEvent {
  final String walletId;

  ExpenseDeleteWallet(this.walletId);
}
