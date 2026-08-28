import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:expense_tracker/core/error/failure.dart';

class UpdateWallet implements UseCase<Wallet, Wallet> {
  final ExpenseRepository repository;

  UpdateWallet(this.repository);

  @override
  Future<Either<Failure, Wallet>> call(Wallet wallet) async {
    return await repository.updateWallet(wallet);
  }
}
