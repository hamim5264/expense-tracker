import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ResetPassword implements UseCase<bool, ResetPasswordParams> {
  final AuthRepository authRepository;

  const ResetPassword(this.authRepository);

  @override
  Future<Either<Failure, bool>> call(ResetPasswordParams params) async {
    return await authRepository.resetPassword(
      email: params.email,
      answer: params.answer,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams {
  final String email;
  final String answer;
  final String newPassword;

  ResetPasswordParams({
    required this.email,
    required this.answer,
    required this.newPassword,
  });
}
