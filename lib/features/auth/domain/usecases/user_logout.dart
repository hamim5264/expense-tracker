import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogout implements UseCase<void, NoParams> {
  final AuthRepository authRepository;

  const UserLogout(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await authRepository.logout();
  }
}
