import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/profile_page.dart';
import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/balance_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/home_shimmer_loading.dart';
import 'package:expense_tracker/features/expense/presentation/pages/add_expense_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/wallet_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/connect_wallet_page.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/all_transactions_sheet.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/sms_detected_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/transaction_item_tile.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/empty_transactions_placeholder.dart';
import 'package:expense_tracker/core/common/utils/sms_parser.dart';
import 'package:expense_tracker/core/common/utils/sms_import_tracker.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:expense_tracker/init_dependencies.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/pages/statistics_page.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';
import 'package:expense_tracker/core/common/utils/rate_us_service.dart';
import 'package:flutter/rendering.dart';

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
  bool _isNavBarVisible = true;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Widget body = BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthInitial) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
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
              bodyContent = WalletPage(onBackTap: () => _onTabSelected(0));
            } else if (_selectedIndex == 3) {
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
                    final isLoading =
                        authState is AuthLoading || expenseState is ExpenseLoading;

                    List<Expense> transactionList = [];

                    if (expenseState is ExpenseSuccess) {
                      transactionList = List.from(expenseState.expenses);
                      transactionList.sort((a, b) => b.date.compareTo(a.date));
                    }

                    return Stack(
                      children: [
                        CustomPaint(
                          size: Size(MediaQuery.of(context).size.width, 300),
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
                                child: Column(
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                               Text(
                                                 _getDynamicDailyGreeting(),
                                                 style: const TextStyle(
                                                   color: Colors.white70,
                                                   fontSize: 12,
                                                   letterSpacing: 0.2,
                                                 ),
                                               ),
                                              Text(
                                                user.username?.isNotEmpty == true
                                                    ? user.username!
                                                    : user.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRouter.onyxAi,
                                                );
                                              },
                                              child: Container(
                                                width: 48,
                                                height: 48,
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withAlpha(
                                                    38,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Lottie.asset(
                                                  'assets/animations/onyx_ai.json',
                                                  fit: BoxFit.contain,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons
                                                            .auto_awesome_rounded,
                                                        color: Colors.white,
                                                        size: 26,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            AnimatedBuilder(
                                               animation: NotificationService(),
                                               builder: (context, _) {
                                                 final unread =
                                                     NotificationService()
                                                         .unreadCount;
                                                 return GestureDetector(
                                                   onTap: () {
                                                     Navigator.pushNamed(
                                                       context,
                                                       AppRouter.notifications,
                                                     );
                                                   },
                                                   behavior: HitTestBehavior.opaque,
                                                   child: Container(
                                                     width: 48,
                                                     height: 48,
                                                     decoration: BoxDecoration(
                                                       color: Colors.white.withAlpha(38),
                                                       borderRadius: BorderRadius.circular(12),
                                                     ),
                                                     child: Stack(
                                                       alignment: Alignment.center,
                                                       children: [
                                                         const Icon(
                                                           CupertinoIcons.bell,
                                                           color: Colors.white,
                                                           size: 24,
                                                         ),
                                                         if (unread > 0)
                                                           Positioned(
                                                             right: 6,
                                                             top: 6,
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
                                                   ),
                                                 );
                                               },
                                             ),
                                          ],
                                        ),
                                      ],
                                    ),
                                     SizedBox(
                                       height: (expenseState is ExpenseSuccess &&
                                               expenseState.wallets.where((w) => w.type == 'card').length > 1)
                                           ? 0
                                           : 32,
                                     ),
                                      BalanceCard(
                                        cardWallets: expenseState is ExpenseSuccess
                                            ? expenseState.wallets.where((w) => w.type == 'card').toList()
                                            : [],
                                        allTransactions: expenseState is ExpenseSuccess
                                            ? expenseState.expenses
                                            : [],
                                        currencyCode: user.currency,
                                        onAddCardTap: () {
                                          Navigator.push(context, ConnectWalletPage.route());
                                        },
                                       ),
                                        const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildActionButton(
                                            context: context,
                                            label: 'Expense',
                                            icon: Icons.north_east_rounded,
                                            iconColor: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFE53935),
                                            onTap: () {
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
                                            isDark: isDark,
                                          ),
                                          const SizedBox(width: 44),
                                          _buildActionButton(
                                            context: context,
                                            label: 'Income',
                                            icon: Icons.south_west_rounded,
                                            iconColor: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF43A047),
                                            onTap: () {
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
                                            isDark: isDark,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                     if (user.smsSyncEnabled &&
                                         _detectedSmsExpenses.isNotEmpty) ...[
                                       Row(
                                         mainAxisAlignment:
                                             MainAxisAlignment.spaceBetween,
                                         children: [
                                           Text(
                                             'Detected from SMS (${_detectedSmsExpenses.length})',
                                             style: const TextStyle(
                                               fontWeight: FontWeight.bold,
                                               fontSize: 15,
                                             ),
                                           ),
                                           GestureDetector(
                                             onTap: _syncAllSmsExpenses,
                                             child: Container(
                                               padding:
                                                   const EdgeInsets.symmetric(
                                                 horizontal: 10,
                                                 vertical: 4,
                                               ),
                                               decoration: BoxDecoration(
                                                 color: theme.primaryColor,
                                                 borderRadius:
                                                     BorderRadius.circular(16),
                                                 boxShadow: [
                                                   BoxShadow(
                                                     color: theme.primaryColor
                                                         .withOpacity(0.3),
                                                     blurRadius: 6,
                                                     offset: const Offset(0, 2),
                                                   ),
                                                 ],
                                               ),
                                               child: const Row(
                                                 mainAxisSize: MainAxisSize.min,
                                                 children: [
                                                   Icon(
                                                     CupertinoIcons
                                                         .arrow_2_circlepath,
                                                     size: 11,
                                                     color: Colors.white,
                                                   ),
                                                   SizedBox(width: 4),
                                                   Text(
                                                     'Sync All',
                                                     style: TextStyle(
                                                       fontSize: 11,
                                                       fontWeight:
                                                           FontWeight.bold,
                                                       color: Colors.white,
                                                     ),
                                                   ),
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
                                       const SizedBox(height: 12),
                                     ],

                                     Row(
                                       mainAxisAlignment:
                                           MainAxisAlignment.spaceBetween,
                                       children: [
                                         const Text(
                                           'Recent Transactions',
                                           style: TextStyle(
                                             fontSize: 15.5,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),
                                         GestureDetector(
                                           onTap: () {
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
                                           child: Container(
                                             padding:
                                                 const EdgeInsets.symmetric(
                                               horizontal: 10,
                                               vertical: 4,
                                             ),
                                             decoration: BoxDecoration(
                                               color: theme.primaryColor,
                                               borderRadius:
                                                   BorderRadius.circular(12),
                                               boxShadow: [
                                                 BoxShadow(
                                                   color: theme.primaryColor
                                                       .withOpacity(0.3),
                                                   blurRadius: 4,
                                                   offset: const Offset(0, 2),
                                                 ),
                                               ],
                                             ),
                                             child: Text(
                                               'See All',
                                               style: TextStyle(
                                                 fontSize: 11.5,
                                                 fontWeight: FontWeight.bold,
                                                 color: theme.primaryColor
                                                             .computeLuminance() >
                                                         0.45
                                                     ? Colors.black87
                                                     : Colors.white,
                                               ),
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                    const SizedBox(height: 8),

                                    Expanded(
                                      child: transactionList.isEmpty
                                          ? const EmptyTransactionsPlaceholder()
                                          : NotificationListener<UserScrollNotification>(
                                              onNotification: (notification) {
                                                if (notification.direction == ScrollDirection.reverse) {
                                                  if (_isNavBarVisible) {
                                                    setState(() => _isNavBarVisible = false);
                                                  }
                                                } else if (notification.direction == ScrollDirection.forward) {
                                                  if (!_isNavBarVisible) {
                                                    setState(() => _isNavBarVisible = true);
                                                  }
                                                }
                                                return true;
                                              },
                                              child: ListView.builder(
                                                controller: _scrollController,
                                                physics: const BouncingScrollPhysics(),
                                                padding: const EdgeInsets.only(bottom: 100),
                                                itemCount: transactionList.length > 10
                                                    ? 10
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
                                            ),
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
            _buildFloatingNavBar(isDark),
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

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      _checkForSmsExpenses();
    }
  }

  Widget _buildNavItem(IconData icon, int index, bool isDark) {
    bool isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Icon(
          icon,
          color: isSelected
              ? (isDark ? Colors.white : theme.primaryColor)
              : (isDark ? Colors.white38 : Colors.grey.shade600),
          size: isSelected ? 24 : 22,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    Widget buttonIcon = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? null : Colors.grey.shade100,
        gradient: isDark
            ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.18)
              : Colors.black.withOpacity(0.05),
          width: isDark ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );

    if (isDark) {
      buttonIcon = ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: buttonIcon,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          buttonIcon,
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar(bool isDark) {
    final theme = Theme.of(context);
    Widget navContent = Container(
      height: 60,
      width: 290,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.25)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.18)
              : Colors.black.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 6 + (_selectedIndex * ((290 - 12) / 4)),
            top: 5,
            child: Container(
              width: (290 - 12) / 4,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: isDark
                    ? Colors.white.withOpacity(0.18)
                    : theme.primaryColor.withOpacity(0.12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.12)
                      : theme.primaryColor.withOpacity(0.2),
                  width: 1.0,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildNavItem(Icons.home_rounded, 0, isDark),
              ),
              Expanded(
                child: _buildNavItem(Icons.bar_chart_rounded, 1, isDark),
              ),
              Expanded(
                child: _buildNavItem(
                  Icons.account_balance_wallet_outlined,
                  2,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  Icons.person_outline_rounded,
                  3,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      bottom: _isNavBarVisible ? 20 : -100,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: navContent,
          ),
        ),
      ),
    );
  }
}
