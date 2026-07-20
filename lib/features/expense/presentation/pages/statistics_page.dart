import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/transaction_item_tile.dart';

import 'package:expense_tracker/features/expense/presentation/widgets/statistics_shimmer_loading.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/statistics_chart.dart';
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

            final totalAmount = _selectedType == 'income'
                ? totalIncome
                : totalExpenses;

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
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Download Statement'),
                                  content: const Text(
                                    'Do you want to download a PDF copy of your transactions statement?',
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
                                        PdfReportService.generateAndSaveReport(
                                          transactions: allPeriodTransactions,
                                          userName:
                                              user.username?.isNotEmpty == true
                                              ? user.username!
                                              : user.name,
                                          currency: user.currency,
                                          period: _selectedPeriod,
                                          type: _selectedType,
                                          totalAmount: totalAmount,
                                          onSuccess: (_) =>
                                              AnimationHelper.showSuccess(
                                                context,
                                                'onyx Report saved successfully!',
                                              ),
                                          onFailed: (err) =>
                                              AnimationHelper.showFailed(
                                                context,
                                                'Export failed: $err',
                                              ),
                                        );
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

                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['Day', 'Week', 'Month', 'Year'].map((
                          period,
                        ) {
                          final isSelected = _selectedPeriod == period;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPeriod = period;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  period,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white60
                                              : Colors.grey.shade600),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withAlpha(20)
                                      : Colors.white.withAlpha(200),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withAlpha(35)
                                        : Colors.white.withAlpha(220),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withAlpha(60)
                                          : Colors.black.withAlpha(15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedType = 'income';
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: _selectedType == 'income'
                                                    ? const Color(
                                                        0xFF22C55E,
                                                      ).withOpacity(0.1)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color:
                                                      _selectedType == 'income'
                                                      ? const Color(
                                                          0xFF22C55E,
                                                        ).withOpacity(0.3)
                                                      : Colors.transparent,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Color(
                                                                0xFF4ADE80,
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Income',
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Colors.white70
                                                              : Colors.black54,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              _selectedType ==
                                                                  'income'
                                                              ? FontWeight.bold
                                                              : FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      CurrencyService.format(
                                                        totalIncome,
                                                        user.currency,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF22C55E,
                                                        ),
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 44,
                                          color: isDark
                                              ? Colors.white24
                                              : Colors.grey.shade300,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedType = 'expense';
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color:
                                                    _selectedType == 'expense'
                                                    ? const Color(
                                                        0xFFEF4444,
                                                      ).withOpacity(0.1)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color:
                                                      _selectedType == 'expense'
                                                      ? const Color(
                                                          0xFFEF4444,
                                                        ).withOpacity(0.3)
                                                      : Colors.transparent,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Color(
                                                                0xFFFF6B6B,
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Expenses',
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Colors.white70
                                                              : Colors.black54,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              _selectedType ==
                                                                  'expense'
                                                              ? FontWeight.bold
                                                              : FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      CurrencyService.format(
                                                        totalExpenses,
                                                        user.currency,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFEF4444,
                                                        ),
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.grey.shade200,
                                      height: 1,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Total ${_selectedType == 'expense' ? 'Spendings' : 'Earnings'}',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  CurrencyService.format(
                                                    totalAmount,
                                                    user.currency,
                                                  ),
                                                  style: TextStyle(
                                                    color:
                                                        _selectedType ==
                                                            'income'
                                                        ? const Color(
                                                            0xFF22C55E,
                                                          )
                                                        : const Color(
                                                            0xFFEF4444,
                                                          ),
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Builder(
                                          builder: (context) {
                                            final net =
                                                totalIncome - totalExpenses;
                                            final isPositive = net >= 0;
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              constraints: const BoxConstraints(
                                                maxWidth: 150,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (isPositive
                                                            ? const Color(
                                                                0xFF22C55E,
                                                              )
                                                            : const Color(
                                                                0xFFEF4444,
                                                              ))
                                                        .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color:
                                                      (isPositive
                                                              ? const Color(
                                                                  0xFF22C55E,
                                                                )
                                                              : const Color(
                                                                  0xFFEF4444,
                                                                ))
                                                          .withOpacity(0.3),
                                                  width: 1.2,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Net Balance',
                                                    style: TextStyle(
                                                      color: isDark
                                                          ? Colors.white60
                                                          : Colors.black54,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      CurrencyService.format(
                                                        net,
                                                        user.currency,
                                                      ),
                                                      style: TextStyle(
                                                        color: isPositive
                                                            ? const Color(
                                                                0xFF22C55E,
                                                              )
                                                            : const Color(
                                                                0xFFEF4444,
                                                              ),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          StatisticsChart(
                            points: chartData,
                            selectedPeriod: _selectedPeriod,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 32),

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
                          const SizedBox(height: 32),
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
