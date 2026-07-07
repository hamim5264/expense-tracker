import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userId = await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      );
      return right(userId);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, String>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final userId = await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );
      return right(userId);
    } on Failure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, String>> signInWithGoogle() async {
    try {
      final userId = await remoteDataSource.signInWithGoogle();
      return right(userId);
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
}
