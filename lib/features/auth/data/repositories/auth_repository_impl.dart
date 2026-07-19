import 'package:expense_tracker/core/common/entities/user.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('User not logged in!'));
      }

      return right(user);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      );
      return currentUser();
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );
      return currentUser();
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      await remoteDataSource.signInWithGoogle();
      return currentUser();
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, void>> signInWithFacebook() async {
    try {
      await remoteDataSource.signInWithFacebook();
      return right(null);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    required String name,
    required String? username,
    required String? avatarUrl,
    String? currency,
    bool? smsSyncEnabled,
  }) async {
    try {
      final user = await remoteDataSource.updateUserProfile(
        name: name,
        username: username,
        avatarUrl: avatarUrl,
        currency: currency,
        smsSyncEnabled: smsSyncEnabled,
      );
      return right(user);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
      return right(null);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return right(null);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, String>> getSecurityQuestion(String email) async {
    try {
      final question = await remoteDataSource.getSecurityQuestion(email);
      return right(question);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String answer,
    required String newPassword,
  }) async {
    try {
      final success = await remoteDataSource.resetPassword(
        email: email,
        answer: answer,
        newPassword: newPassword,
      );
      if (success) {
        return right(true);
      } else {
        return left(Failure('Security answer is incorrect!'));
      }
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return right(null);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, User>> updateSecurityQuestionAnswer({
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final user = await remoteDataSource.updateSecurityQuestionAnswer(
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );
      return right(user);
    } on Failure catch (e) {
      return left(e);
    }
  }
}
