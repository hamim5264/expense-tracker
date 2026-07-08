part of 'expense_bloc.dart';

@immutable
sealed class ExpenseEvent {}

final class ExpenseFetchAll extends ExpenseEvent {}
