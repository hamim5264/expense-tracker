import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/core/common/utils/animation_helper.dart';
import 'package:expense_tracker/core/common/utils/pdf_report_service.dart';
import 'package:expense_tracker/features/expense/presentation/pages/connect_wallet_page.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/wallet_shimmer_loading.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/quick_action_button.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/wallet_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
              List<Expense> expenses = [];
              if (expenseState is ExpenseSuccess) {
                wallets = expenseState.wallets;
                expenses = expenseState.expenses;
              }

              double totalWalletBalance = 0;
              for (var w in wallets) {
                totalWalletBalance += w.balance;
              }

              return Stack(
                children: [
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 330),
                    painter: HeaderPainter(
                      color: Theme.of(context).primaryColor,
                    ),
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
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.notifications,
                                  );
                                },
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
                              icon: Icons.swap_horiz_rounded,
                              label: 'Transfer',
                              onTap: () => _showTransferDialog(
                                context,
                                wallets,
                                user.id,
                              ),
                            ),
                            QuickActionButton(
                              icon: Icons.download_rounded,
                              label: 'Export',
                              onTap: () => _exportTransactions(
                                expenses,
                                wallets,
                                user.name.isEmpty
                                    ? user.email.split('@').first
                                    : user.name,
                                user.currency,
                              ),
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

  void _showTransferDialog(
    BuildContext context,
    List<Wallet> wallets,
    String userId,
  ) {
    if (wallets.length < 2) {
      Fluttertoast.showToast(
        msg: 'You need at least 2 wallets to transfer funds.',
      );
      return;
    }

    Wallet fromWallet = wallets.first;
    Wallet toWallet = wallets[1];
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final primaryColor = const Color(0xFF4F378A);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1B24) : Colors.white,
              title: const Text(
                'Transfer Funds',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'From Wallet',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Wallet>(
                      initialValue: fromWallet,
                      dropdownColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      items: wallets.map((w) {
                        return DropdownMenuItem(value: w, child: Text(w.name));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            fromWallet = val;
                            if (fromWallet == toWallet) {
                              toWallet = wallets.firstWhere(
                                (w) => w != fromWallet,
                              );
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'To Wallet',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Wallet>(
                      initialValue: toWallet,
                      dropdownColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      items: wallets.where((w) => w != fromWallet).map((w) {
                        return DropdownMenuItem(value: w, child: Text(w.name));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => toWallet = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Amount',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(hintText: '0.00'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount <= 0) {
                      Fluttertoast.showToast(msg: 'Enter a valid amount');
                      return;
                    }

                    final expenseBloc = context.read<ExpenseBloc>();

                    final debitTx = Expense(
                      id: '',
                      userId: userId,
                      title: 'Transfer to ${toWallet.name}',
                      amount: amount,
                      date: DateTime.now(),
                      type: 'expense',
                      category: 'Transfer',
                      walletId: fromWallet.id,
                    );

                    final creditTx = Expense(
                      id: '',
                      userId: userId,
                      title: 'Transfer from ${fromWallet.name}',
                      amount: amount,
                      date: DateTime.now(),
                      type: 'income',
                      category: 'Transfer',
                      walletId: toWallet.id,
                    );

                    expenseBloc.add(ExpenseAddTransaction(debitTx));
                    expenseBloc.add(ExpenseAddTransaction(creditTx));

                    Navigator.pop(dialogContext);
                    AnimationHelper.showSuccess(
                      context,
                      'Transfer completed successfully!',
                    );
                    expenseBloc.add(ExpenseFetchAll());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Transfer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportTransactions(
    List<Expense> expenses,
    List<Wallet> wallets,
    String userName,
    String currency,
  ) async {
    if (expenses.isEmpty) {
      if (!mounted) return;
      AnimationHelper.showFailed(context, 'No transactions to export.');
      return;
    }

    final totalBalance = wallets.fold(0.0, (sum, w) => sum + w.balance);

    await PdfReportService.generateAndSaveReport(
      transactions: expenses,
      userName: userName,
      currency: currency,
      period: 'all',
      type: 'all',
      totalAmount: totalBalance,
      onSuccess: (_) {
        if (!mounted) return;
        AnimationHelper.showSuccess(context, 'onyx Report saved to Downloads!');
      },
      onFailed: (err) {
        if (!mounted) return;
        AnimationHelper.showFailed(context, 'Export failed: $err');
      },
    );
  }
}
