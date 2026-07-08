part of 'expense_bloc.dart';

@immutable
sealed class ExpenseState {}

final class ExpenseInitial extends ExpenseState {}

final class ExpenseLoading extends ExpenseState {}

final class ExpenseSuccess extends ExpenseState {
  final List<Expense> expenses;

  ExpenseSuccess(this.expenses);
}

final class ExpenseFailure extends ExpenseState {
  final String message;

  ExpenseFailure(this.message);
}
