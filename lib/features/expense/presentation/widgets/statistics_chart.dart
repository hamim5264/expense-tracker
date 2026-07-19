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

    final gradientColors = [const Color(0xFF311B92), const Color(0xFF5E35B1)];
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
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: selectedPeriod == 'Day' ? 4 : 1,
                getTitlesWidget: (value, meta) {
                  String text = '';
                  final valInt = value.toInt();
                  if (selectedPeriod == 'Day') {
                    text = '$valInt:00';
                  } else if (selectedPeriod == 'Week') {
                    text = '$valInt';
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
              getTooltipColor: (LineBarSpot touchedSpot) =>
                  const Color(0xFF311B92),
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
        ),
      ),
    );
  }
}
