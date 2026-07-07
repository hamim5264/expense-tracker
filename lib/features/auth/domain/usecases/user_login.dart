import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogin implements UseCase<String, UserLoginParams> {
  final AuthRepository authRepository;

  const UserLogin(this.authRepository);

  @override
  Future<Either<Failure, String>> call(UserLoginParams params) async {
    return await authRepository.loginWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams({required this.email, required this.password});
}
