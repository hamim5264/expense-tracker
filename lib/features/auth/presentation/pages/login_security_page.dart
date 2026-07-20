import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/password_update_form.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/security_question_form.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class LoginSecurityPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const LoginSecurityPage());

  const LoginSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.scaffoldBackgroundColor : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final supabaseUser = Supabase.instance.client.auth.currentUser;
    final isSocialLogin =
        supabaseUser?.appMetadata['provider'] == 'google' ||
        supabaseUser?.appMetadata['provider'] == 'facebook';
    final providerName = supabaseUser?.appMetadata['provider'] == 'google'
        ? 'Google'
        : 'Facebook';

    return Scaffold(
      backgroundColor: cardColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            showToast('Security settings updated successfully!');
          } else if (state is AuthFailure) {
            showToast(state.message, isError: true);
          } else if (state is AuthInitial) {
            showToast('Password updated. Please log in again.');
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 280),
                painter: HeaderPainter(color: Theme.of(context).primaryColor),
              ),
              Positioned(
                top: -20,
                left: -20,
                child: Opacity(
                  opacity: 0.80,
                  child: Image.asset(
                    'assets/images/components/background_design.png',
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Login and Security',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state is AuthLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            if (isSocialLogin) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1B24)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.black12,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withAlpha(20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.security_rounded,
                                        color: Theme.of(context).primaryColor,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Social Account Connected',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Your account is securely linked via $providerName. Password updates and security configurations are managed directly by your social provider.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                            ] else ...[
                              Text(
                                'Update Password',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const PasswordUpdateForm(),
                              const SizedBox(height: 40),
                              Text(
                                'Security Question Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const SecurityQuestionForm(),
                              const SizedBox(height: 40),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
