import 'package:flutter/foundation.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String securityQuestion;
  final String securityAnswer;

  AuthSignUp({
    required this.email,
    required this.password,
    required this.name,
    required this.securityQuestion,
    required this.securityAnswer,
  });
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({required this.email, required this.password});
}

final class AuthGoogleSignIn extends AuthEvent {}

final class AuthIsUserLoggedIn extends AuthEvent {}

final class AuthLogout extends AuthEvent {}

final class AuthUpdateUserProfile extends AuthEvent {
  final String name;
  final String? username;
  final String? avatarUrl;
  final String? currency;
  final bool? smsSyncEnabled;

  AuthUpdateUserProfile({
    required this.name,
    this.username,
    this.avatarUrl,
    this.currency,
    this.smsSyncEnabled,
  });
}

final class AuthUpdatePassword extends AuthEvent {
  final String password;

  AuthUpdatePassword(this.password);
}

final class AuthForgotPasswordFetchQuestion extends AuthEvent {
  final String email;

  AuthForgotPasswordFetchQuestion(this.email);
}

final class AuthResetPassword extends AuthEvent {
  final String email;
  final String answer;
  final String newPassword;

  AuthResetPassword({
    required this.email,
    required this.answer,
    required this.newPassword,
  });
}

final class AuthDeleteAccount extends AuthEvent {}

final class AuthUpdateSecurityQuestionAnswer extends AuthEvent {
  final String securityQuestion;
  final String securityAnswer;

  AuthUpdateSecurityQuestionAnswer({
    required this.securityQuestion,
    required this.securityAnswer,
  });
}
