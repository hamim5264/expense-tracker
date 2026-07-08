import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/expense/data/datasources/expense_remote_data_source.dart';
import 'package:expense_tracker/features/expense/data/models/expense_model.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Expense>>> getAllExpenses() async {
    try {
      final expenses = await remoteDataSource.getAllExpenses();
      return right(expenses);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel(
        id: expense.id,
        userId: expense.userId,
        title: expense.title,
        amount: expense.amount,
        date: expense.date,
        type: expense.type,
      );
      await remoteDataSource.addExpense(expenseModel);
      return right(null);
    } on Failure catch (e) {
      return left(e);
    }
  }
}
