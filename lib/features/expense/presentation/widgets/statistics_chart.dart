import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartPoint {
  final double x;
  final double y;

  const ChartPoint(this.x, this.y);
}

class StatisticsChart extends StatelessWidget {
  final List<ChartPoint> points;
  final String selectedPeriod;
  final bool isDark;

  const StatisticsChart({
    super.key,
    required this.points,
    required this.selectedPeriod,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No data available for this range',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final primaryColor = Theme.of(context).primaryColor;
    final lineGradient = LinearGradient(
      colors: isDark
          ? [
              const Color(0xFF818CF8), // Indigo Glow
              const Color(0xFFC084FC), // Purple Glow
              primaryColor,
            ]
          : [
              primaryColor,
              primaryColor.withOpacity(0.8),
              const Color(0xFF6366F1),
            ],
    );

    final spots = points.map((p) => FlSpot(p.x, p.y)).toList();

    double maxY = 100;
    for (var p in points) {
      if (p.y > maxY) maxY = p.y;
    }
    maxY = (maxY * 1.15).ceilToDouble();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: maxY / 3,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  String formatted;
                  if (value >= 1000) {
                    formatted = '${(value / 1000).toStringAsFixed(1)}k';
                  } else {
                    formatted = value.toStringAsFixed(0);
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      formatted,
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                        fontSize: 9.5,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: selectedPeriod == 'Day' ? 4 : 1,
                getTitlesWidget: (value, meta) {
                  String text = '';
                  final valInt = value.toInt();
                  if (selectedPeriod == 'Day') {
                    text = '$valInt:00';
                  } else if (selectedPeriod == 'Week') {
                    final days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                    text = (valInt >= 0 && valInt < days.length) ? days[valInt] : '$valInt';
                  } else if (selectedPeriod == 'Month') {
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
                    space: 6,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.black.withOpacity(0.08),
                width: 1,
              ),
              left: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          minX: points.first.x,
          maxX: points.last.x,
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot touchedSpot) =>
                  isDark ? const Color(0xFF2D2A3E) : const Color(0xFF1E1B29),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tooltipMargin: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '\$${spot.y.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
              curveSmoothness: 0.35,
              preventCurveOverShooting: true,
              gradient: lineGradient,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4.5,
                      color: isDark ? const Color(0xFFC084FC) : primaryColor,
                      strokeWidth: 2.5,
                      strokeColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    (isDark ? const Color(0xFF818CF8) : primaryColor).withOpacity(0.35),
                    (isDark ? const Color(0xFFC084FC) : primaryColor).withOpacity(0.08),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
