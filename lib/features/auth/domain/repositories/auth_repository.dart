import 'package:expense_tracker/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, String>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  });

  Future<Either<Failure, String>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, String>> signInWithGoogle();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, String>> getSecurityQuestion(String email);

  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String answer,
    required String newPassword,
  });
}
