import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/export_data_card.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/delete_account_card.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataPrivacyPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const DataPrivacyPage());

  const DataPrivacyPage({super.key});

  @override
  State<DataPrivacyPage> createState() => _DataPrivacyPageState();
}

class _DataPrivacyPageState extends State<DataPrivacyPage> {
  @override
  void initState() {
    super.initState();
    final expenseState = context.read<ExpenseBloc>().state;
    if (expenseState is! ExpenseSuccess) {
      context.read<ExpenseBloc>().add(ExpenseFetchAll());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.scaffoldBackgroundColor : Colors.white;

    return Scaffold(
      backgroundColor: cardColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            showToast('Your account was permanently deleted.');
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
          } else if (state is AuthFailure) {
            showToast(state.message, isError: true);
          }
        },
        child: Stack(
          children: [
            // 1. Purple Header Background
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 280),
              painter: HeaderPainter(),
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
                              'Data and Privacy',
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
                  const Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExportDataCard(),
                          SizedBox(height: 24),
                          DeleteAccountCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
