import 'package:expense_tracker/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/signup_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/splash_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/home_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/notifications_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/onyx_ai_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String onyxAi = '/onyx-ai';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';

    if (routeName.startsWith('/?code=') ||
        routeName.contains('login-callback')) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          backgroundColor: Color(0xFF4F378A),
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

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
      case notifications:
        return NotificationsPage.route();
      case onyxAi:
        return OnyxAiPage.route();
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
