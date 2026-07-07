import 'package:expense_tracker/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/signup_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/splash_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return SplashPage.route();
      case login:
        return LoginPage.route();
      case signup:
        return SignUpPage.route();
      case forgotPassword:
        return ForgotPasswordPage.route();
      case home:
        return HomePage.route();
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
