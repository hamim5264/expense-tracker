import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/expense/presentation/pages/connect_wallet_page.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/wallet_shimmer_loading.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/quick_action_button.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/wallet_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletPage extends StatefulWidget {
  final VoidCallback? onBackTap;

  const WalletPage({super.key, this.onBackTap});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(ExpenseFetchAll());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF9F9FB),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = authState.user;

          return BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, expenseState) {
              if (expenseState is ExpenseLoading ||
                  expenseState is ExpenseInitial) {
                return const WalletShimmerLoading();
              }

              if (expenseState is ExpenseFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load wallets',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          expenseState.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.read<ExpenseBloc>().add(
                            ExpenseFetchAll(),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F378A),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              List<Wallet> wallets = [];
              if (expenseState is ExpenseSuccess) {
                wallets = expenseState.wallets;
              }

              double totalWalletBalance = 0;
              for (var w in wallets) {
                totalWalletBalance += w.balance;
              }

              return Stack(
                children: [
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 330),
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
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                ),
                                onPressed:
                                    widget.onBackTap ??
                                    () => Navigator.pop(context),
                              ),
                              const Text(
                                'Wallet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Total Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyService.format(
                            totalWalletBalance,
                            user.currency,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            QuickActionButton(
                              icon: Icons.add,
                              label: 'Add',
                              onTap: () {
                                final bloc = context.read<ExpenseBloc>();
                                Navigator.push(
                                  context,
                                  ConnectWalletPage.route(),
                                ).then((_) => bloc.add(ExpenseFetchAll()));
                              },
                            ),
                            QuickActionButton(
                              icon: Icons.qr_code_scanner_rounded,
                              label: 'Pay',
                              onTap: () {},
                            ),
                            QuickActionButton(
                              icon: Icons.send_rounded,
                              label: 'Send',
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          child: wallets.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No linked wallets or cards yet.',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          final bloc = context
                                              .read<ExpenseBloc>();
                                          Navigator.push(
                                            context,
                                            ConnectWalletPage.route(),
                                          ).then(
                                            (_) => bloc.add(ExpenseFetchAll()),
                                          );
                                        },
                                        child: const Text(
                                          'Connect a Wallet',
                                          style: TextStyle(
                                            color: Color(0xFF4F378A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  itemCount: wallets.length,
                                  itemBuilder: (context, index) {
                                    final wallet = wallets[index];
                                    return WalletItemTile(
                                      wallet: wallet,
                                      currencyCode: user.currency,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
