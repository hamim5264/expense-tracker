import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/transaction_item_tile.dart';

import 'package:expense_tracker/features/expense/presentation/widgets/statistics_shimmer_loading.dart';
import 'package:expense_tracker/core/common/utils/pdf_report_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

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

            final typedTransactions = allTransactions
                .where((tx) => tx.type == _selectedType)
                .toList();

            final periodTransactions = _filterByPeriod(
              typedTransactions,
              _selectedPeriod,
            );

            final chartData = _generateChartData(
              periodTransactions,
              _selectedPeriod,
            );

            final totalAmount = periodTransactions.fold<double>(
              0.0,
              (sum, tx) => sum + tx.amount,
            );

            final sortedTransactions = List<Expense>.from(periodTransactions)
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
                              if (Navigator.canPop(context)) {
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
                                          transactions: periodTransactions,
                                          userName:
                                              user.username?.isNotEmpty == true
                                              ? user.username!
                                              : user.name,
                                          currency: user.currency,
                                          period: _selectedPeriod,
                                          type: _selectedType,
                                          totalAmount: totalAmount,
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
                                      ? const Color(0xFF4F378A)
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

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedType,
                                dropdownColor: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'expense',
                                    child: Text(
                                      'Expense',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'income',
                                    child: Text(
                                      'Income',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedType = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
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
                                    Text(
                                      CurrencyService.format(
                                        totalAmount,
                                        user.currency,
                                      ),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          if (chartData.isNotEmpty)
                            SizedBox(
                              height: 220,
                              child: LineChart(
                                _mainChartData(chartData, isDark),
                              ),
                            )
                          else
                            const SizedBox(
                              height: 220,
                              child: Center(
                                child: Text(
                                  'No data available for this period',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
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

  List<_ChartPoint> _generateChartData(List<Expense> list, String period) {
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
    return sortedKeys.map((k) => _ChartPoint(k.toDouble(), map[k]!)).toList();
  }

  LineChartData _mainChartData(List<_ChartPoint> points, bool isDark) {
    final gradientColors = [const Color(0xFF311B92), const Color(0xFF5E35B1)];

    final spots = points.map((p) => FlSpot(p.x, p.y)).toList();

    double maxY = 100;
    for (var p in points) {
      if (p.y > maxY) maxY = p.y;
    }
    maxY = (maxY * 1.15).ceilToDouble();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDark ? Colors.white10 : Colors.grey.shade300,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _selectedPeriod == 'Day' ? 4 : 1,
            getTitlesWidget: (value, meta) {
              String text = '';
              final valInt = value.toInt();
              if (_selectedPeriod == 'Day') {
                text = '$valInt:00';
              } else if (_selectedPeriod == 'Week') {
                text = '$valInt';
              } else if (_selectedPeriod == 'Month') {
                text = 'Wk $valInt';
              } else {
                switch (valInt) {
                  case 1:
                    text = 'Jan';
                    break;
                  case 3:
                    text = 'Mar';
                    break;
                  case 5:
                    text = 'May';
                    break;
                  case 7:
                    text = 'Jul';
                    break;
                  case 9:
                    text = 'Sep';
                    break;
                  case 11:
                    text = 'Nov';
                    break;
                }
              }
              return SideTitleWidget(
                meta: meta,
                space: 8,
                child: Text(
                  text,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: points.first.x,
      maxX: points.last.x,
      minY: 0,
      maxY: maxY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot touchedSpot) => const Color(0xFF311B92),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '\$${spot.y.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 6,
                  color: const Color(0xFF311B92),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withAlpha(50))
                  .toList(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartPoint {
  final double x;
  final double y;

  const _ChartPoint(this.x, this.y);
}
