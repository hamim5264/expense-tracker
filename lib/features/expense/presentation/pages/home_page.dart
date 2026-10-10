import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/profile_page.dart';
import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/home_shimmer_loading.dart';
import 'package:expense_tracker/features/expense/presentation/pages/add_expense_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/wallet_page.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/all_transactions_sheet.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/sms_detected_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/transaction_item_tile.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/money_flow_chart.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/empty_transactions_placeholder.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/home_spending_summary_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/quick_add_expense_buttons.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/home_top_header_widget.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/floating_nav_bar_widget.dart';
import 'package:expense_tracker/core/common/utils/sms_parser.dart';
import 'package:expense_tracker/core/common/utils/sms_import_tracker.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:expense_tracker/init_dependencies.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/pages/statistics_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/budget_master_page.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';
import 'package:expense_tracker/core/common/utils/rate_us_service.dart';

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
  // ignore: unused_field
  bool _isScanningSms = false;
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription? _smsSubscription;
  bool _isOffline = false;
  int _activeCardIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(ExpenseFetchAll());
    _requestSmsPermissionAndScan();
    _setupConnectivityListener();
    _setupIncomingSmsSubscription();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        RateUsService.checkAndShowRateUsDialog(context);
        NotificationService().fetchRemoteAnnouncements();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySubscription?.cancel();
    _smsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _requestSmsPermissionAndScan() async {
    _checkForSmsExpenses();
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

  void _setupIncomingSmsSubscription() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user.smsSyncEnabled) {
      const EventChannel smsChannel = EventChannel('com.thedevhamim.onyx/sms');
      _smsSubscription = smsChannel.receiveBroadcastStream().listen((event) {
        final data = Map<String, dynamic>.from(event);
        final body = data['body'] as String? ?? '';
        final sender = data['sender'] as String? ?? 'SMS Alert';
        final timestamp =
            data['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;

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
      }, onError: (err) {});
    }
  }

  Future<void> _checkForSmsExpenses() async {
    final authState = context.read<AuthBloc>().state;
    final expenseState = context.read<ExpenseBloc>().state;
    if (authState is AuthSuccess && authState.user.smsSyncEnabled) {
      setState(() => _isScanningSms = true);
      List<Expense> existing = [];
      if (expenseState is ExpenseSuccess) {
        existing = expenseState.expenses;
      }

      final detected = await SmsParser.scanSmsForExpenses(
        authState.user.id,
        existingExpenses: existing,
      );

      setState(() {
        _detectedSmsExpenses = detected;
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
    SmsImportTracker.markAsImported(expense.id);
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

  void _syncAllSmsExpenses() {
    if (_detectedSmsExpenses.isEmpty) return;

    final expenseState = context.read<ExpenseBloc>().state;
    String? targetWalletId;
    if (expenseState is ExpenseSuccess && expenseState.wallets.isNotEmpty) {
      targetWalletId = expenseState.wallets.first.id;
    }

    if (targetWalletId == null) {
      showSnackBar(context, 'Please connect a wallet first.', isError: true);
      return;
    }

    final count = _detectedSmsExpenses.length;
    final itemsToSync = List<Expense>.from(_detectedSmsExpenses);

    for (final expense in itemsToSync) {
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
      SmsImportTracker.markAsImported(expense.id);
    }

    setState(() {
      _detectedSmsExpenses.clear();
    });

    showSnackBar(
      context,
      'Synced $count SMS transaction${count > 1 ? 's' : ''}!',
    );
  }

  String _getDynamicDailyGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday; // 1 (Mon) to 7 (Sun)

    String timeOfDay;
    if (hour >= 5 && hour < 12) {
      timeOfDay = 'Morning';
    } else if (hour >= 12 && hour < 17) {
      timeOfDay = 'Afternoon';
    } else if (hour >= 17 && hour < 22) {
      timeOfDay = 'Evening';
    } else {
      timeOfDay = 'Night';
    }

    final greetings = {
      1: 'Fresh Start Monday $timeOfDay,',
      2: 'Thriving Tuesday $timeOfDay,',
      3: 'Productive Wednesday $timeOfDay,',
      4: 'Thoughtful Thursday $timeOfDay,',
      5: 'Fantastic Friday $timeOfDay,',
      6: 'Serene Saturday $timeOfDay,',
      7: 'Peaceful Sunday $timeOfDay,',
    };

    return greetings[weekday] ?? 'Good $timeOfDay,';
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      _checkForSmsExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Widget body = BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
        } else if (state is AuthFailure) {
          showSnackBar(context, state.message, isError: true);
        }
      },
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = authState.user;

        Widget bodyContent;

        if (_selectedIndex == 1) {
          bodyContent = StatisticsPage(onBackTap: () => _onTabSelected(0));
        } else if (_selectedIndex == 2) {
          bodyContent = BudgetMasterPage(onBackTap: () => _onTabSelected(0));
        } else if (_selectedIndex == 3) {
          bodyContent = WalletPage(onBackTap: () => _onTabSelected(0));
        } else if (_selectedIndex == 4) {
          bodyContent = ProfilePage(onBackTap: () => _onTabSelected(0));
        } else {
          bodyContent = BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, expenseState) {
              if (expenseState is ExpenseSuccess) {
                _checkForSmsExpenses();
              }
            },
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, expenseState) {
                final isLoading = authState is AuthLoading || expenseState is ExpenseLoading;

                List<Expense> transactionList = [];
                if (expenseState is ExpenseSuccess) {
                  transactionList = List.from(expenseState.expenses);
                  transactionList.sort((a, b) => b.date.compareTo(a.date));
                }

                final isLightPrimary = theme.primaryColor.computeLuminance() > 0.45;

                return isLoading
                    ? Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: CustomPaint(
                              size: Size(MediaQuery.of(context).size.width, 358),
                              painter: HeaderPainter(color: theme.primaryColor),
                            ),
                          ),
                          Positioned(
                            top: -30,
                            left: -30,
                            child: Opacity(
                              opacity: 1.0,
                              child: Image.asset(
                                'assets/images/components/background_design.png',
                                width: 320,
                                fit: BoxFit.contain,
                                color: isLightPrimary
                                    ? Colors.black.withOpacity(0.04)
                                    : Colors.white.withOpacity(0.45),
                                colorBlendMode: BlendMode.srcATop,
                              ),
                            ),
                          ),
                          const SafeArea(child: HomeShimmerLoading()),
                        ],
                      )
                    : Column(
                        children: [
                          // Header with purple background that wraps content naturally
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -30,
                                  left: -30,
                                  child: IgnorePointer(
                                    child: Opacity(
                                      opacity: 1.0,
                                      child: Image.asset(
                                        'assets/images/components/background_design.png',
                                        width: 320,
                                        fit: BoxFit.contain,
                                        color: isLightPrimary
                                            ? Colors.black.withOpacity(0.04)
                                            : Colors.white.withOpacity(0.45),
                                        colorBlendMode: BlendMode.srcATop,
                                      ),
                                    ),
                                  ),
                                ),
                                SafeArea(
                                  bottom: false,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                                    child: HomeTopHeaderWidget(
                                      user: user,
                                      wallets: expenseState is ExpenseSuccess ? expenseState.wallets : [],
                                      allExpenses: transactionList,
                                      activeCardIndex: _activeCardIndex,
                                      isOffline: _isOffline,
                                      isDark: isDark,
                                      greetingText: _getDynamicDailyGreeting(),
                                      onPageChanged: (idx) => setState(() => _activeCardIndex = idx),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Scrollable content below header
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                context.read<ExpenseBloc>().add(ExpenseFetchAll());
                                await _checkForSmsExpenses();
                              },
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 24),
                                    QuickAddExpenseButtons(
                                      isDark: isDark,
                                      onAddExpense: () {
                                        final wallets = expenseState is ExpenseSuccess ? expenseState.wallets : [];
                                        if (wallets.isEmpty) {
                                          showToast('Please add a card or wallet first.', isError: true, context: context);
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          AddExpensePage.route(initialType: 'expense'),
                                        );
                                      },
                                      onAddIncome: () {
                                        final wallets = expenseState is ExpenseSuccess ? expenseState.wallets : [];
                                        if (wallets.isEmpty) {
                                          showToast('Please add a card or wallet first.', isError: true, context: context);
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          AddExpensePage.route(initialType: 'income'),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 18),

                                    HomeSpendingSummaryCard(
                                      allExpenses: transactionList,
                                      currencyCode: user.currency,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 16),

                                    if (user.smsSyncEnabled && _detectedSmsExpenses.isNotEmpty) ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Detected from SMS (${_detectedSmsExpenses.length})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          GestureDetector(
                                            onTap: _syncAllSmsExpenses,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(CupertinoIcons.arrow_2_circlepath, size: 11, color: isLightPrimary ? Colors.black87 : Colors.white),
                                                  const SizedBox(width: 4),
                                                  Text('Sync All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isLightPrimary ? Colors.black87 : Colors.white)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 96,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _detectedSmsExpenses.length,
                                          itemBuilder: (context, index) {
                                            final item = _detectedSmsExpenses[index];
                                            return SmsDetectedCard(
                                              item: item,
                                              currencyCode: user.currency,
                                              isDark: isDark,
                                              onSync: () => _syncSmsExpense(item),
                                              onDiscard: () => _discardSmsExpense(item.id),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Recent Transactions', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold)),
                                        GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              backgroundColor: Colors.transparent,
                                              isScrollControlled: true,
                                              barrierColor: Colors.black.withAlpha(80),
                                              builder: (sheetContext) => AllTransactionsSheet(
                                                transactions: transactionList,
                                                currencyCode: user.currency,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: theme.primaryColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'See All',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: theme.primaryColor.computeLuminance() > 0.45 ? Colors.black87 : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    if (transactionList.isEmpty)
                                      const EmptyTransactionsPlaceholder()
                                    else
                                      ...transactionList.take(5).map((tx) => TransactionItemTile(
                                            transaction: tx,
                                            currencyCode: user.currency,
                                            isDark: isDark,
                                          )),
                                    const SizedBox(height: 16),

                                    Text(
                                      'Money Flow Analytics',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    MoneyFlowChart(
                                      transactions: transactionList,
                                      currencyCode: user.currency,
                                      isDark: isDark,
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
        }

        return Stack(
          children: [
            bodyContent,
            FloatingNavBarWidget(
              selectedIndex: _selectedIndex,
              isDark: isDark,
              primaryColor: theme.primaryColor,
              onTabSelected: _onTabSelected,
            ),
          ],
        );
      },
    );

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: body,
        bottomNavigationBar: null,
      ),
    );
  }
}
