import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/core/common/widgets/loader.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage());

  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final answerController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isObscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    answerController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: onSurface),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showToast(state.message, isError: true);
          } else if (state is AuthPasswordResetSuccess) {
            showToast('Password reset successful! Please login.');
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          state is AuthQuestionLoaded
                              ? 'Reset Password'
                              : 'Forgot Password?',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state is AuthQuestionLoaded
                              ? 'Answer your security question to set a new password.'
                              : "Don't worry! It happens. Please enter the email address linked with your account.",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF6A707C),
                          ),
                        ),
                        const SizedBox(height: 32),

                        if (state is! AuthQuestionLoaded) ...[
                          AuthField(
                            hintText: 'Enter your email',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  AuthForgotPasswordFetchQuestion(
                                    emailController.text.trim(),
                                  ),
                                );
                              }
                            },
                            child: const Text('Verify Email'),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFF7F8F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE8ECF4),
                              ),
                            ),
                            child: Text(
                              state.question,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          AuthField(
                            hintText: 'Your Answer',
                            controller: answerController,
                          ),
                          const SizedBox(height: 15),
                          AuthField(
                            hintText: 'New Password',
                            controller: passwordController,
                            isObscureText: isObscureText,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isObscureText = !isObscureText;
                                });
                              },
                              icon: Icon(
                                isObscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF6A707C),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          AuthField(
                            hintText: 'Confirm Password',
                            controller: confirmPasswordController,
                            isObscureText: isObscureText,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if (passwordController.text !=
                                    confirmPasswordController.text) {
                                  showToast(
                                    'Passwords do not match!',
                                    isError: true,
                                  );
                                  return;
                                }
                                context.read<AuthBloc>().add(
                                  AuthResetPassword(
                                    email: emailController.text.trim(),
                                    answer: answerController.text
                                        .trim()
                                        .toLowerCase(),
                                    newPassword: passwordController.text.trim(),
                                  ),
                                );
                              }
                            },
                            child: const Text('Reset Password'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (state is AuthLoading) const BlurLoader(),
            ],
          );
        },
      ),
    );
  }
}
