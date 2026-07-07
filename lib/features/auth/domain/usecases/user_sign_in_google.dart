import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignInGoogle implements UseCase<String, NoParams> {
  final AuthRepository authRepository;

  const UserSignInGoogle(this.authRepository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await authRepository.signInWithGoogle();
  }
}
