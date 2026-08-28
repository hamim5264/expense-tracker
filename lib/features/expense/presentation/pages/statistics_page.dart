import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/transaction_item_tile.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/statistics_shimmer_loading.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/statistics_chart.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/category_bubble_widget.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/statistics_summary_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/period_selector_bar.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/core/common/utils/pdf_report_service.dart';
import 'package:expense_tracker/core/common/utils/animation_helper.dart';

class StatisticsPage extends StatefulWidget {
  final VoidCallback? onBackTap;

  const StatisticsPage({super.key, this.onBackTap});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedPeriod = 'Month';
  String _selectedType = 'expense';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = authState.user;

        return BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, expenseState) {
            if (expenseState is ExpenseLoading ||
                expenseState is ExpenseInitial) {
              return Scaffold(
                backgroundColor: isDark
                    ? const Color(0xFF121212)
                    : const Color(0xFFF9F9FB),
                body: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: StatisticsShimmerLoading(),
                  ),
                ),
              );
            }

            List<Expense> allTransactions = [];
            if (expenseState is ExpenseSuccess) {
              allTransactions = expenseState.expenses;
            }

            final allPeriodTransactions = _filterByPeriod(
              allTransactions,
              _selectedPeriod,
            );

            final totalIncome = allPeriodTransactions
                .where((tx) => tx.type == 'income')
                .fold<double>(0.0, (sum, tx) => sum + tx.amount);

            final totalExpenses = allPeriodTransactions
                .where((tx) => tx.type == 'expense')
                .fold<double>(0.0, (sum, tx) => sum + tx.amount);

            final typedTransactions = allPeriodTransactions
                .where((tx) => tx.type == _selectedType)
                .toList();

            final chartData = _generateChartData(
              typedTransactions,
              _selectedPeriod,
            );

            final sortedTransactions = List<Expense>.from(typedTransactions)
              ..sort((a, b) => b.amount.compareTo(a.amount));

            return Scaffold(
              backgroundColor: isDark
                  ? const Color(0xFF121212)
                  : const Color(0xFFF9F9FB),
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            onPressed: () {
                              if (widget.onBackTap != null) {
                                widget.onBackTap!();
                              } else if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          Text(
                            'Statistics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.file_download_outlined,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            onPressed: () {
                              if (allPeriodTransactions.isEmpty) {
                                showToast(
                                  'Cannot export: No transactions found for $_selectedPeriod.',
                                  isError: true,
                                  context: context,
                                );
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Download Statement',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  content: Text(
                                    'Do you want to download a PDF statement for $_selectedPeriod?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        showExportProgressDialog(context);

                                        Future.microtask(() async {
                                          await PdfReportService.generateAndSaveReport(
                                            transactions: allPeriodTransactions,
                                            userName: user.username?.isNotEmpty == true
                                                ? user.username!
                                                : user.name,
                                            currency: user.currency,
                                            period: _selectedPeriod,
                                            type: 'all',
                                            totalAmount: totalIncome - totalExpenses,
                                            onSuccess: (_) {
                                              if (context.mounted) {
                                                Navigator.of(context, rootNavigator: true).pop();
                                                AnimationHelper.showSuccess(
                                                  context,
                                                  'Report saved to Downloads & App Reports!',
                                                );
                                              }
                                            },
                                            onFailed: (err) {
                                              if (context.mounted) {
                                                Navigator.of(context, rootNavigator: true).pop();
                                                AnimationHelper.showFailed(
                                                  context,
                                                  'Export failed: $err',
                                                );
                                              }
                                            },
                                          );
                                        });
                                      },
                                      child: const Text('Download'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    PeriodSelectorBar(
                      selectedPeriod: _selectedPeriod,
                      isDark: isDark,
                      primaryColor: theme.primaryColor,
                      onPeriodSelected: (p) => setState(() => _selectedPeriod = p),
                    ),

                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          const SizedBox(height: 12),
                          StatisticsSummaryCard(
                            selectedType: _selectedType,
                            totalIncome: totalIncome,
                            totalExpenses: totalExpenses,
                            currencyCode: user.currency,
                            isDark: isDark,
                            onTypeChanged: (t) => setState(() => _selectedType = t),
                          ),
                          const SizedBox(height: 32),

                          // Category Bubble Cloud Section
                          Builder(
                            builder: (context) {
                              final typeTx = allPeriodTransactions.where((t) => t.type == _selectedType).toList();
                              final double periodTotal = typeTx.fold(0.0, (s, t) => s + t.amount);

                              if (periodTotal == 0 || typeTx.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final Map<String, double> categorySums = {};
                              for (var tx in typeTx) {
                                categorySums[tx.category] = (categorySums[tx.category] ?? 0.0) + tx.amount;
                              }

                              IconData getCupertinoIconForCat(String cat) {
                                final l = cat.toLowerCase();
                                if (l.contains('food') || l.contains('grocer')) return CupertinoIcons.cart_fill;
                                if (l.contains('dine') || l.contains('cafe') || l.contains('rest')) return CupertinoIcons.heart_fill;
                                if (l.contains('health') || l.contains('medical') || l.contains('doctor')) return CupertinoIcons.heart_fill;
                                if (l.contains('cloth') || l.contains('shoe') || l.contains('wear') || l.contains('shop')) return CupertinoIcons.bag_fill;
                                if (l.contains('sport') || l.contains('gym') || l.contains('fit')) return CupertinoIcons.sportscourt;
                                if (l.contains('travel') || l.contains('trip') || l.contains('agency') || l.contains('flight')) return CupertinoIcons.airplane;
                                if (l.contains('bill') || l.contains('phone') || l.contains('utilit')) return CupertinoIcons.device_phone_portrait;
                                if (l.contains('ent') || l.contains('mov') || l.contains('game')) return CupertinoIcons.tv_fill;
                                if (l.contains('salary') || l.contains('income') || l.contains('pay')) return CupertinoIcons.money_dollar;
                                return CupertinoIcons.circle_grid_hex;
                              }

                              Color getColorForIndex(int idx) {
                                const colors = [
                                  Color(0xFF2563EB),
                                  Color(0xFF0D9488),
                                  Color(0xFF7C3AED),
                                  Color(0xFFE11D48),
                                  Color(0xFFD97706),
                                  Color(0xFF059669),
                                  Color(0xFF0284C7),
                                  Color(0xFFBE185D),
                                ];
                                return colors[idx % colors.length];
                              }

                              int colorIdx = 0;
                              final bubbleDataList = categorySums.entries.map((entry) {
                                final pct = (entry.value / periodTotal) * 100;
                                return CategoryBubbleData(
                                  category: entry.key,
                                  amount: entry.value,
                                  percentage: pct,
                                  icon: getCupertinoIconForCat(entry.key),
                                  color: getColorForIndex(colorIdx++),
                                );
                              }).toList();

                              return Column(
                                children: [
                                  CategoryBubbleCloudSection(
                                    categoryData: bubbleDataList,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              );
                            },
                          ),

                          StatisticsChart(
                            points: chartData,
                            selectedPeriod: _selectedPeriod,
                            isDark: isDark,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedType == 'expense'
                                    ? 'Top Spending'
                                    : 'Top Earnings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Icon(
                                Icons.swap_vert_rounded,
                                color: isDark ? Colors.white60 : Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (sortedTransactions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No transactions recorded',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ...sortedTransactions.map((tx) {
                              return TransactionItemTile(
                                transaction: tx,
                                currencyCode: user.currency,
                                isDark: isDark,
                              );
                            }),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Expense> _filterByPeriod(List<Expense> list, String period) {
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
      } else {
        return tx.date.year == now.year;
      }
    }).toList();
  }

  List<ChartPoint> _generateChartData(List<Expense> list, String period) {
    final Map<int, double> map = {};

    if (period == 'Day') {
      for (int i = 0; i < 24; i += 4) {
        map[i] = 0.0;
      }
      for (var tx in list) {
        final hourBin = (tx.date.hour ~/ 4) * 4;
        map[hourBin] = (map[hourBin] ?? 0.0) + tx.amount;
      }
    } else if (period == 'Week') {
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        map[d.day] = 0.0;
      }
      for (var tx in list) {
        final dayKey = tx.date.day;
        if (map.containsKey(dayKey)) {
          map[dayKey] = (map[dayKey] ?? 0.0) + tx.amount;
        }
      }
    } else if (period == 'Month') {
      for (int i = 1; i <= 4; i++) {
        map[i] = 0.0;
      }
      for (var tx in list) {
        final week = ((tx.date.day - 1) ~/ 7) + 1;
        final clampedWeek = week.clamp(1, 4);
        map[clampedWeek] = (map[clampedWeek] ?? 0.0) + tx.amount;
      }
    } else {
      for (int i = 1; i <= 12; i++) {
        map[i] = 0.0;
      }
      for (var tx in list) {
        final m = tx.date.month;
        map[m] = (map[m] ?? 0.0) + tx.amount;
      }
    }

    final sortedKeys = map.keys.toList()..sort();
    return sortedKeys.map((k) => ChartPoint(k.toDouble(), map[k]!)).toList();
  }
}

