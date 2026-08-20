import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/core/common/utils/animation_helper.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/core/common/utils/pdf_report_service.dart';
import 'package:expense_tracker/features/expense/presentation/pages/connect_wallet_page.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/wallet_shimmer_loading.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/quick_action_button.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/wallet_item_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';

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
                            backgroundColor: theme.primaryColor,
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
                              AnimatedBuilder(
                                animation: NotificationService(),
                                builder: (context, _) {
                                  final unread = NotificationService().unreadCount;
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRouter.notifications,
                                      );
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            CupertinoIcons.bell,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        if (unread > 0)
                                          Positioned(
                                            right: 4,
                                            top: 4,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEF4444),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Theme.of(context).primaryColor,
                                                  width: 1.5,
                                                ),
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Text(
                                                unread > 9 ? '9+' : '$unread',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CurrencyService.format(
                                totalWalletBalance,
                                user.currency,
                              ),
                              style: TextStyle(
                                color: totalWalletBalance < 0
                                    ? const Color(0xFFFF6B6B)
                                    : Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                              onTap: () => _showExportPeriodSheet(
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
                        const SizedBox(height: 48),
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
                                        child: Text(
                                          'Connect a Wallet',
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: 24,
                                    right: 24,
                                    top: 24,
                                    bottom: 100,
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

  List<Expense> _filterByPeriod(List<Expense> list, String period) {
    if (period == 'All Time' || period == 'all') return list;
    final now = DateTime.now();
    return list.where((tx) {
      if (period == 'Day') {
        return tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day;
      } else if (period == 'Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
        final startOfCurrentWeek = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        return tx.date.isAfter(startOfCurrentWeek) ||
            (tx.date.year == startOfCurrentWeek.year &&
                tx.date.month == startOfCurrentWeek.month &&
                tx.date.day == startOfCurrentWeek.day);
      } else if (period == 'Month') {
        return tx.date.year == now.year && tx.date.month == now.month;
      } else if (period == 'Year') {
        return tx.date.year == now.year;
      }
      return true;
    }).toList();
  }

  void _showExportPeriodSheet(
    List<Expense> expenses,
    List<Wallet> wallets,
    String userName,
    String currency,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final primaryColor = Theme.of(sheetContext).primaryColor;
        final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;

        final options = [
          {'id': 'Day', 'label': "Today's Statement", 'icon': CupertinoIcons.calendar_today},
          {'id': 'Week', 'label': 'This Week', 'icon': CupertinoIcons.calendar},
          {'id': 'Month', 'label': 'This Month', 'icon': CupertinoIcons.calendar_badge_minus},
          {'id': 'Year', 'label': 'This Year', 'icon': CupertinoIcons.calendar_badge_plus},
          {'id': 'All Time', 'label': 'All Time Statement', 'icon': CupertinoIcons.infinite},
        ];

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Statement Timeframe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...options.map((opt) {
                    final id = opt['id'] as String;
                    final label = opt['label'] as String;
                    final icon = opt['icon'] as IconData;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                          ),
                        ),
                        tileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: primaryColor, size: 18),
                        ),
                        title: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _exportTransactions(
                            expenses,
                            wallets,
                            userName,
                            currency,
                            period: id,
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportTransactions(
    List<Expense> expenses,
    List<Wallet> wallets,
    String userName,
    String currency, {
    String period = 'all',
  }) async {
    final filteredExpenses = _filterByPeriod(expenses, period);

    if (filteredExpenses.isEmpty) {
      if (!mounted) return;
      showToast('Cannot export: No transactions found for $period.', isError: true, context: context);
      return;
    }

    final totalBalance = wallets.fold(0.0, (sum, w) => sum + w.balance);

    showExportProgressDialog(context);

    Future.microtask(() async {
      await PdfReportService.generateAndSaveReport(
        transactions: filteredExpenses,
        userName: userName,
        currency: currency,
        period: period,
        type: 'all',
        totalAmount: totalBalance,
        onSuccess: (_) {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          AnimationHelper.showSuccess(
            context,
            'Report saved to Downloads & App Reports!',
          );
        },
        onFailed: (err) {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          AnimationHelper.showFailed(context, 'Export failed: $err');
        },
      );
    });
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
        final primaryColor = Theme.of(dialogContext).primaryColor;

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
}
