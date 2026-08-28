import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';

class MoneyFlowChart extends StatefulWidget {
  final List<Expense> transactions;
  final String currencyCode;
  final bool isDark;

  const MoneyFlowChart({
    super.key,
    required this.transactions,
    required this.currencyCode,
    required this.isDark,
  });

  @override
  State<MoneyFlowChart> createState() => _MoneyFlowChartState();
}

class _MoneyFlowChartState extends State<MoneyFlowChart> {
  // Filters: '7D', '30D', '1Y'
  String _selectedFilter = '7D';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = widget.isDark;

    final labelColor = isDark ? Colors.white60 : Colors.grey.shade600;

    // Green for Income, Red/Orange for Expense
    const incomeLineColor = Color(0xFF22C55E);
    const expenseLineColor = Color(0xFFEF4444);

    final dataPoints = _processChartData();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildLegendDot(incomeLineColor, 'Income'),
                  const SizedBox(width: 14),
                  _buildLegendDot(expenseLineColor, 'Expense'),
                ],
              ),

              // Filter Buttons Pill
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildFilterTab('7D', '7 Days', primaryColor, isDark),
                    _buildFilterTab('30D', '30 Days', primaryColor, isDark),
                    _buildFilterTab('1Y', '1 Year', primaryColor, isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart Container
          SizedBox(
            height: 180,
            child: dataPoints.isEmpty
                ? Center(
                    child: Text(
                      'No transaction data for $_selectedFilter',
                      style: TextStyle(fontSize: 12, color: labelColor),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: _calculateBottomInterval(dataPoints.length),
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= dataPoints.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  dataPoints[idx].label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: labelColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => isDark
                              ? const Color(0xFF2D2A3E)
                              : Colors.white,
                          tooltipBorder: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                          tooltipMargin: 8,
                          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((barSpot) {
                              final isIncomeLine = barSpot.barIndex == 0;
                              final label = isIncomeLine ? 'Income' : 'Expense';
                              final valStr = CurrencyService.format(
                                barSpot.y,
                                widget.currencyCode,
                              );
                              return LineTooltipItem(
                                '$label: $valStr',
                                TextStyle(
                                  color: isIncomeLine ? incomeLineColor : expenseLineColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        // Line 1: Income
                        LineChartBarData(
                          spots: dataPoints
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                              .toList(),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: incomeLineColor,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: dataPoints.length <= 12,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: incomeLineColor,
                                strokeWidth: 1.5,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                incomeLineColor.withOpacity(0.25),
                                incomeLineColor.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),

                        // Line 2: Expense
                        LineChartBarData(
                          spots: dataPoints
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.expense))
                              .toList(),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: expenseLineColor,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: dataPoints.length <= 12,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: expenseLineColor,
                                strokeWidth: 1.5,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                expenseLineColor.withOpacity(0.20),
                                expenseLineColor.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: widget.isDark ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(
    String code,
    String tooltipLabel,
    Color primaryColor,
    bool isDark,
  ) {
    final isSelected = _selectedFilter == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          code,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? (primaryColor.computeLuminance() > 0.45 ? Colors.black87 : Colors.white)
                : (isDark ? Colors.white60 : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  double _calculateBottomInterval(int length) {
    if (length <= 7) return 1.0;
    if (length <= 12) return 1.0;
    if (length <= 30) return 5.0;
    return (length / 6).floorToDouble();
  }

  List<_ChartPoint> _processChartData() {
    final now = DateTime.now();

    if (_selectedFilter == '7D') {
      // Last 7 Days
      final List<_ChartPoint> points = [];
      for (int i = 6; i >= 0; i--) {
        final dayDate = DateTime(now.year, now.month, now.day - i);
        final dayName = _getDayAbbreviation(dayDate.weekday);

        double dayIncome = 0.0;
        double dayExpense = 0.0;

        for (var tx in widget.transactions) {
          if (tx.date.year == dayDate.year &&
              tx.date.month == dayDate.month &&
              tx.date.day == dayDate.day) {
            if (tx.type == 'income') {
              dayIncome += tx.amount;
            } else {
              dayExpense += tx.amount;
            }
          }
        }
        points.add(_ChartPoint(label: dayName, income: dayIncome, expense: dayExpense));
      }
      return points;
    } else if (_selectedFilter == '30D') {
      // Last 30 Days (grouped into 6 5-day intervals)
      final List<_ChartPoint> points = [];
      for (int i = 29; i >= 0; i -= 5) {
        final startDate = DateTime(now.year, now.month, now.day - i);
        final endDate = startDate.add(const Duration(days: 4));
        final label = '${startDate.day}/${startDate.month}';

        double rangeIncome = 0.0;
        double rangeExpense = 0.0;

        for (var tx in widget.transactions) {
          if (!tx.date.isBefore(startDate) && tx.date.isBefore(endDate.add(const Duration(days: 1)))) {
            if (tx.type == 'income') {
              rangeIncome += tx.amount;
            } else {
              rangeExpense += tx.amount;
            }
          }
        }
        points.add(_ChartPoint(label: label, income: rangeIncome, expense: rangeExpense));
      }
      return points;
    } else {
      // 1 Year (12 Months)
      final List<_ChartPoint> points = [];
      for (int i = 11; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthName = _getMonthAbbreviation(monthDate.month);

        double monthIncome = 0.0;
        double monthExpense = 0.0;

        for (var tx in widget.transactions) {
          if (tx.date.year == monthDate.year && tx.date.month == monthDate.month) {
            if (tx.type == 'income') {
              monthIncome += tx.amount;
            } else {
              monthExpense += tx.amount;
            }
          }
        }
        points.add(_ChartPoint(label: monthName, income: monthIncome, expense: monthExpense));
      }
      return points;
    }
  }

  String _getDayAbbreviation(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }
}

class _ChartPoint {
  final String label;
  final double income;
  final double expense;

  _ChartPoint({
    required this.label,
    required this.income,
    required this.expense,
  });
}
