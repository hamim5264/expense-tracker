import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/core/common/widgets/loader.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/auth_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/social_button.dart';
import 'package:expense_tracker/features/expense/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const LoginPage());

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isObscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showToast(state.message, isError: true);
            } else if (state is AuthSuccess) {
              showToast('Login Successful!');
              Navigator.pushAndRemoveUntil(
                context,
                HomePage.route(),
                (route) => false,
              );
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
                          const SizedBox(height: 30),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white.withAlpha(8)
                                    : const Color(0xFF4F378A).withAlpha(15),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white.withAlpha(20)
                                      : const Color(0xFF4F378A).withAlpha(35),
                                ),
                                child: Image.asset(
                                  'assets/images/logos/app_final_splash_logo.png',
                                  height: 80,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Welcome back! Glad\nto see you, Again!',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthField(
                            hintText: 'Enter your email',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          AuthField(
                            hintText: 'Enter your password',
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF6A707C),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  AuthLogin(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  ),
                                );
                              }
                            },
                            child: const Text('Login'),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              'Or Login with',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF6A707C),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              SocialButton(
                                icon: Image.asset(
                                  'assets/images/components/facebook.png',
                                  height: 26,
                                ),
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    AuthFacebookSignIn(),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              SocialButton(
                                icon: Image.asset(
                                  'assets/images/components/google.png',
                                  height: 26,
                                ),
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    AuthGoogleSignIn(),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Don’t have an account? ",
                                  style: GoogleFonts.inter(
                                    color: onSurface,
                                    fontSize: 15,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Register Now',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF4F378A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
      ),
    );
  }
}
