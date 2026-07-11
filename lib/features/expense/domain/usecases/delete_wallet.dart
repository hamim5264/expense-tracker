import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:expense_tracker/core/error/failure.dart';

class DeleteWallet implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteWallet(this.repository);

  @override
  Future<Either<Failure, void>> call(String walletId) async {
    return await repository.deleteWallet(walletId);
  }
}
