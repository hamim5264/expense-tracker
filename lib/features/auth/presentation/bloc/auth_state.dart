import 'package:expense_tracker/core/common/entities/user.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess(this.user);
}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

final class AuthQuestionLoaded extends AuthState {
  final String question;

  AuthQuestionLoaded(this.question);
}

final class AuthPasswordResetSuccess extends AuthState {}
