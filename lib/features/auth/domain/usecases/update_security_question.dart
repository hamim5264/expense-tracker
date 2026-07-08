import 'package:expense_tracker/core/common/entities/user.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateSecurityQuestion
    implements UseCase<User, UpdateSecurityQuestionParams> {
  final AuthRepository authRepository;

  UpdateSecurityQuestion(this.authRepository);

  @override
  Future<Either<Failure, User>> call(
    UpdateSecurityQuestionParams params,
  ) async {
    return await authRepository.updateSecurityQuestionAnswer(
      securityQuestion: params.securityQuestion,
      securityAnswer: params.securityAnswer,
    );
  }
}

class UpdateSecurityQuestionParams {
  final String securityQuestion;
  final String securityAnswer;

  UpdateSecurityQuestionParams({
    required this.securityQuestion,
    required this.securityAnswer,
  });
}
