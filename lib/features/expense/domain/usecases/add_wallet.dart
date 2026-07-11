import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddWallet implements UseCase<Wallet, Wallet> {
  final ExpenseRepository repository;

  AddWallet(this.repository);

  @override
  Future<Either<Failure, Wallet>> call(Wallet params) async {
    return await repository.addWallet(params);
  }
}
