import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteExpense implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteExpense(params);
  }
}
