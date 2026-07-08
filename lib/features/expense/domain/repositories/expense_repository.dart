import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getAllExpenses();

  Future<Either<Failure, void>> addExpense(Expense expense);
}
