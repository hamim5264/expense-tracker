import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/profile_page.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/balance_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/home_shimmer_loading.dart';
import 'package:expense_tracker/features/expense/presentation/pages/add_expense_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/wallet_page.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/all_transactions_sheet.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/sms_detected_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/transaction_item_tile.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/empty_transactions_placeholder.dart';
import 'package:expense_tracker/core/common/utils/sms_parser.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:expense_tracker/init_dependencies.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/pages/statistics_page.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';

class HomePage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const HomePage());

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Expense> _detectedSmsExpenses = [];
  bool _isScanningSms = false;
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription? _smsSubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(ExpenseFetchAll());
    _checkForSmsExpenses();
    _setupConnectivityListener();
    _setupIncomingSmsSubscription();
  }

  void _setupConnectivityListener() {
    final networkInfo = serviceLocator<NetworkInfo>();
    networkInfo.isConnected.then((connected) {
      if (mounted) {
        setState(() => _isOffline = !connected);
      }
    });

    _connectivitySubscription = networkInfo.onConnectionChanged.listen((
      connected,
    ) {
      if (mounted) {
        setState(() => _isOffline = !connected);
        if (connected) {
          showSnackBar(
            context,
            'Internet restored! Syncing offline transactions...',
          );
          final repo =
              serviceLocator<ExpenseRepository>() as ExpenseRepositoryImpl;
          repo.syncUnsyncedData().then((_) {
            if (mounted) {
              context.read<ExpenseBloc>().add(ExpenseFetchAll());
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _smsSubscription?.cancel();
    super.dispose();
  }

  void _setupIncomingSmsSubscription() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user.smsSyncEnabled) {
      const EventChannel smsChannel = EventChannel(
        'com.example.expense_tracker/sms',
      );
      _smsSubscription = smsChannel.receiveBroadcastStream().listen(
        (event) {
          final data = Map<String, dynamic>.from(event);
          final body = data['body'] as String? ?? '';
          final sender = data['sender'] as String? ?? 'SMS Alert';
          final timestamp =
              data['timestamp'] as int? ??
              DateTime.now().millisecondsSinceEpoch;

          final lowerBody = body.toLowerCase();
          if (lowerBody.contains('debited') ||
              lowerBody.contains('spent') ||
              lowerBody.contains('payment') ||
              lowerBody.contains('charged') ||
              lowerBody.contains('purchase') ||
              lowerBody.contains('transaction')) {
            final amountRegex = RegExp(
              r'(?:bdt|tk|\$|usd|debited|charged|spent)\s*([\d,]+(?:\.\d{1,2})?)|([\d,]+(?:\.\d{1,2})?)\s*(?:bdt|tk|\$|usd|taka)',
              caseSensitive: false,
            );
            final match = amountRegex.firstMatch(body);
            if (match != null) {
              final amountStr = match.group(1) ?? match.group(2);
              if (amountStr != null) {
                final cleanedVal = amountStr.replaceAll(',', '');
                final amount = double.tryParse(cleanedVal) ?? 0.0;
                if (amount > 0) {
                  String category = 'Others';
                  if (lowerBody.contains('food') ||
                      lowerBody.contains('restaurant')) {
                    category = 'Food';
                  } else if (lowerBody.contains('shop') ||
                      lowerBody.contains('grocer')) {
                    category = 'Shopping';
                  }

                  final tx = Expense(
                    id: timestamp.toString(),
                    userId: authState.user.id,
                    title: 'Auto: $sender',
                    amount: amount,
                    date: DateTime.fromMillisecondsSinceEpoch(timestamp),
                    type: 'expense',
                    category: category,
                  );

                  if (mounted) {
                    setState(() {
                      _detectedSmsExpenses.insert(0, tx);
                    });
                    showSnackBar(context, 'New transactional SMS detected!');
                  }
                }
              }
            }
          }
        },
        onError: (err) {
          // Ignored
        },
      );
    }
  }

  Future<void> _checkForSmsExpenses() async {
    final authState = context.read<AuthBloc>().state;
    final expenseState = context.read<ExpenseBloc>().state;
    if (authState is AuthSuccess && authState.user.smsSyncEnabled) {
      setState(() => _isScanningSms = true);
      final detected = await SmsParser.scanSmsForExpenses(authState.user.id);

      List<Expense> existing = [];
      if (expenseState is ExpenseSuccess) {
        existing = expenseState.expenses;
      }

      final filtered = detected.where((det) {
        final alreadyExists = existing.any(
          (ext) =>
              (ext.amount - det.amount).abs() < 0.01 &&
              ext.date.year == det.date.year &&
              ext.date.month == det.date.month &&
              ext.date.day == det.date.day,
        );
        return !alreadyExists;
      }).toList();

      setState(() {
        _detectedSmsExpenses = filtered;
        _isScanningSms = false;
      });
    }
  }

  void _syncSmsExpense(Expense expense) {
    final expenseState = context.read<ExpenseBloc>().state;
    String? targetWalletId;
    if (expenseState is ExpenseSuccess && expenseState.wallets.isNotEmpty) {
      targetWalletId = expenseState.wallets.first.id;
    }

    if (targetWalletId == null) {
      showSnackBar(context, 'Please connect a wallet first.', isError: true);
      return;
    }

    final finalExpense = Expense(
      id: '',
      userId: expense.userId,
      title: expense.title.startsWith('Auto: ')
          ? expense.title.substring(6)
          : expense.title,
      amount: expense.amount,
      date: expense.date,
      type: expense.type,
      category: expense.category,
      walletId: targetWalletId,
    );

    context.read<ExpenseBloc>().add(ExpenseAddTransaction(finalExpense));
    setState(() {
      _detectedSmsExpenses.removeWhere((item) => item.id == expense.id);
    });
    showSnackBar(context, 'Transaction synced!');
  }

  void _discardSmsExpense(String id) {
    setState(() {
      _detectedSmsExpenses.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = authState.user;

          if (user.smsSyncEnabled &&
              _detectedSmsExpenses.isEmpty &&
              !_isScanningSms) {
            _checkForSmsExpenses();
          }

          if (_selectedIndex == 2) {
            return WalletPage(
              onBackTap: () => setState(() => _selectedIndex = 0),
            );
          }

          if (_selectedIndex == 3) {
            return ProfilePage(
              onBackTap: () => setState(() => _selectedIndex = 0),
            );
          }

          if (_selectedIndex == 1) {
            return const StatisticsPage();
          }

          return BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, expenseState) {
              if (expenseState is ExpenseSuccess) {
                _checkForSmsExpenses();
              }
            },
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, expenseState) {
                final isLoading =
                    authState is AuthLoading || expenseState is ExpenseLoading;

                double totalBalance = 0;
                double income = 0;
                double expenses = 0;
                List<Expense> transactionList = [];

                if (expenseState is ExpenseSuccess) {
                  transactionList = List.from(expenseState.expenses);
                  transactionList.sort((a, b) => b.date.compareTo(a.date));
                  for (var item in transactionList) {
                    if (item.type == 'income') {
                      income += item.amount;
                    } else {
                      expenses += item.amount;
                    }
                  }
                  totalBalance = income - expenses;
                }

                return Stack(
                  children: [
                    CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 300),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: isLoading
                            ? const HomeShimmerLoading()
                            : RefreshIndicator(
                                onRefresh: () async {
                                  context.read<ExpenseBloc>().add(
                                    ExpenseFetchAll(),
                                  );
                                  await _checkForSmsExpenses();
                                },
                                child: ListView(
                                  children: [
                                    if (_isOffline)
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade900,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.wifi_off_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Offline Mode. Transactions will auto-sync when online.',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    // Top Header Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Good afternoon,',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              user.username?.isNotEmpty == true
                                                  ? user.username!
                                                  : user.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(38),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons
                                                      .notifications_none_rounded,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                              Positioned(
                                                right: 12,
                                                top: 12,
                                                child: Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.orange,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    BalanceCard(
                                      totalBalance: totalBalance,
                                      income: income,
                                      expenses: expenses,
                                      currencyCode: user.currency,
                                    ),
                                    const SizedBox(height: 24),

                                    if (user.smsSyncEnabled &&
                                        _detectedSmsExpenses.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.sms_failed_outlined,
                                            color: Colors.deepOrangeAccent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Detected from SMS (${_detectedSmsExpenses.length})',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 130,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              _detectedSmsExpenses.length,
                                          itemBuilder: (context, index) {
                                            final item =
                                                _detectedSmsExpenses[index];
                                            return SmsDetectedCard(
                                              item: item,
                                              currencyCode: user.currency,
                                              isDark: isDark,
                                              onSync: () =>
                                                  _syncSmsExpense(item),
                                              onDiscard: () =>
                                                  _discardSmsExpense(item.id),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Recent Transactions',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              backgroundColor:
                                                  Colors.transparent,
                                              isScrollControlled: true,
                                              barrierColor: Colors.black
                                                  .withAlpha(80),
                                              builder: (sheetContext) =>
                                                  AllTransactionsSheet(
                                                    transactions:
                                                        transactionList,
                                                    currencyCode: user.currency,
                                                  ),
                                            );
                                          },
                                          child: const Text(
                                            'See All',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    if (transactionList.isEmpty)
                                      const EmptyTransactionsPlaceholder()
                                    else
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: transactionList.length > 5
                                            ? 5
                                            : transactionList.length,
                                        itemBuilder: (context, index) {
                                          final tx = transactionList[index];
                                          return TransactionItemTile(
                                            transaction: tx,
                                            currencyCode: user.currency,
                                            isDark: isDark,
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 20,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 0, isDark),
              _buildNavItem(Icons.bar_chart_rounded, 1, isDark),
              const SizedBox(width: 48),
              _buildNavItem(Icons.account_balance_wallet_outlined, 2, isDark),
              _buildNavItem(Icons.person_outline_rounded, 3, isDark),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F378A).withAlpha(100),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, AddExpensePage.route()),
          backgroundColor: const Color(0xFF311B92),
          shape: const CircleBorder(),
          elevation: 0,
          child: const Icon(Icons.add, color: Color(0xFFD1BCFF), size: 32),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, bool isDark) {
    bool isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected
            ? const Color(0xFF4F378A)
            : (isDark ? Colors.white38 : Colors.grey.shade400),
        size: 28,
      ),
      onPressed: () {
        setState(() => _selectedIndex = index);
      },
    );
  }
}
