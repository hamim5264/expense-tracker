import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUp implements UseCase<String, UserSignUpParams> {
  final AuthRepository authRepository;

  const UserSignUp(this.authRepository);

  @override
  Future<Either<Failure, String>> call(UserSignUpParams params) async {
    return await authRepository.signUpWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
      securityQuestion: params.securityQuestion,
      securityAnswer: params.securityAnswer,
    );
  }
}

class UserSignUpParams {
  final String email;
  final String password;
  final String name;
  final String securityQuestion;
  final String securityAnswer;

  UserSignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.securityQuestion,
    required this.securityAnswer,
  });
}
