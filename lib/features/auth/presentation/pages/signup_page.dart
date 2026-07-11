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

class SignUpPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const SignUpPage());

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final securityAnswerController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isObscureText = true;
  bool isConfirmObscureText = true;

  String? selectedQuestion;
  final List<String> questions = [
    'What was your first pet\'s name?',
    'What is your mother\'s maiden name?',
    'What was the name of your elementary school?',
    'In what city were you born?',
    'What is your favorite book?',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    securityAnswerController.dispose();
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
          } else if (state is AuthSuccess) {
            showToast('Registration Successful!');
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
                        Center(
                          child: Image.asset(
                            'assets/images/logos/app_final_splash_logo.png',
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Nice to meet you',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Before we begin, we need some details.',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color(0xFF6A707C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        AuthField(
                          hintText: 'Username',
                          controller: nameController,
                        ),
                        const SizedBox(height: 15),
                        AuthField(
                          hintText: 'Enter your email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        AuthField(
                          hintText: 'Password',
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
                          hintText: 'Confirm password',
                          controller: confirmPasswordController,
                          isObscureText: isConfirmObscureText,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isConfirmObscureText = !isConfirmObscureText;
                              });
                            },
                            icon: Icon(
                              isConfirmObscureText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF6A707C),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedQuestion,
                          decoration: InputDecoration(
                            hintText: 'Select Security Question',
                            filled: true,
                            fillColor: theme.brightness == Brightness.dark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF7F8F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE8ECF4),
                              ),
                            ),
                          ),
                          items: questions
                              .map(
                                (q) => DropdownMenuItem(
                                  value: q,
                                  child: Text(
                                    q,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedQuestion = val;
                            });
                          },
                          validator: (val) =>
                              val == null ? 'Please select a question' : null,
                        ),
                        const SizedBox(height: 15),
                        AuthField(
                          hintText: 'Your Answer',
                          controller: securityAnswerController,
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
                                AuthSignUp(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  name: nameController.text.trim(),
                                  securityQuestion: selectedQuestion!,
                                  securityAnswer: securityAnswerController.text
                                      .trim()
                                      .toLowerCase(),
                                ),
                              );
                            }
                          },
                          child: const Text('Register'),
                        ),
                        const SizedBox(height: 35),
                        Center(
                          child: Text(
                            'Or Register with',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6A707C),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            SocialButton(
                              icon: Image.asset(
                                'assets/images/components/facebook.png',
                                height: 26,
                              ),
                              onPressed: () {
                                showToast('Facebook login is coming soon!');
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
                            const SizedBox(width: 8),
                            SocialButton(
                              icon: Image.asset(
                                'assets/images/components/apple.png',
                                height: 26,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : null,
                              ),
                              onPressed: () {
                                showToast('Apple login is coming soon!');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: GoogleFonts.inter(
                                  color: onSurface,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Login Now',
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
    );
  }
}
