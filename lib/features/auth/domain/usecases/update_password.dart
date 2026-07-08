import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdatePassword implements UseCase<void, String> {
  final AuthRepository authRepository;

  UpdatePassword(this.authRepository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await authRepository.updatePassword(params);
  }
}
