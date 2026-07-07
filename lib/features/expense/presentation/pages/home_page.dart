import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const HomePage());

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthInitial) {
                Navigator.pushAndRemoveUntil(
                  context,
                  LoginPage.route(),
                  (route) => false,
                );
              }
            },
            child: IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogout());
              },
              icon: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Home',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
