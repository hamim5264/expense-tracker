import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetSecurityQuestion implements UseCase<String, String> {
  final AuthRepository authRepository;

  const GetSecurityQuestion(this.authRepository);

  @override
  Future<Either<Failure, String>> call(String email) async {
    return await authRepository.getSecurityQuestion(email);
  }
}
