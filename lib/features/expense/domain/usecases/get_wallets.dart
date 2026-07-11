import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetWallets implements UseCase<List<Wallet>, NoParams> {
  final ExpenseRepository repository;

  GetWallets(this.repository);

  @override
  Future<Either<Failure, List<Wallet>>> call(NoParams params) async {
    return await repository.getWallets();
  }
}
