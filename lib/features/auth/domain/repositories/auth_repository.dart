import 'package:expense_tracker/core/common/entities/user.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> currentUser();

  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  });

  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, User>> updateUserProfile({
    required String name,
    required String? username,
    required String? avatarUrl,
    String? currency,
    bool? smsSyncEnabled,
  });

  Future<Either<Failure, void>> updatePassword(String newPassword);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, String>> getSecurityQuestion(String email);

  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String answer,
    required String newPassword,
  });

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, User>> updateSecurityQuestionAnswer({
    required String securityQuestion,
    required String securityAnswer,
  });
}
