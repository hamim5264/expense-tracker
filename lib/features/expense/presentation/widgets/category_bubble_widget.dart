import 'dart:math' as math;
import 'package:flutter/material.dart';

class CategoryBubbleData {
  final String category;
  final double amount;
  final double percentage; // e.g. 32.8
  final IconData icon;
  final Color color;

  const CategoryBubbleData({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.color,
  });
}

class CategoryBubbleWidget extends StatelessWidget {
  final CategoryBubbleData data;
  final double size;
  final bool isDark;

  const CategoryBubbleWidget({
    super.key,
    required this.data,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (data.percentage / 100).clamp(0.04, 1.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(isDark ? 0.45 : 0.25),
            blurRadius: 22,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _BubbleGlassPainter(
          progress: progress,
          accentColor: data.color,
          isDark: isDark,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(size * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  data.icon,
                  size: (size * 0.26).clamp(16.0, 36.0),
                  color: Colors.white,
                ),
                SizedBox(height: size * 0.03),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.category,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: (size * 0.11).clamp(9.0, 13.5),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                SizedBox(height: size * 0.02),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${data.percentage.toStringAsFixed(1).replaceAll('.', ',')}%',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (size * 0.14).clamp(10.5, 17.5),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleGlassPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final bool isDark;

  _BubbleGlassPainter({
    required this.progress,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Multi-Stop Glass Sphere Gradient
    final glassPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.95,
        colors: [
          Colors.white.withOpacity(0.40),
          accentColor.withOpacity(isDark ? 0.85 : 0.90),
          accentColor.withOpacity(isDark ? 0.50 : 0.65),
          HSLColor.fromColor(accentColor).withLightness(isDark ? 0.12 : 0.22).toColor().withOpacity(0.95),
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 4, glassPaint);

    // 2. Specular Top Glass Reflection Arc
    final specularPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.55),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 4, specularPaint);

    // 3. Crisp Inner Rim Highlight
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withOpacity(0.40);

    canvas.drawCircle(center, radius - 4, borderPaint);

    // 4. Outer Glowing Progress Arc Rim
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.6
      ..shader = LinearGradient(
        colors: [
          Colors.white,
          Colors.white.withOpacity(0.5),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleGlassPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark;
  }
}

class CategoryBubbleCloudSection extends StatelessWidget {
  final List<CategoryBubbleData> categoryData;
  final bool isDark;

  const CategoryBubbleCloudSection({
    super.key,
    required this.categoryData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort categories by highest percentage, showing up to 10 categories
    final sorted = List<CategoryBubbleData>.from(categoryData)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
    final displayData = sorted.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spending Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${displayData.length} Categories',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Premium Glass Bubble Cloud Grid with Staggered Dynamic Sizing
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E1B2E),
                      const Color(0xFF0B132B),
                    ]
                  : [
                      const Color(0xFFFAFAFE),
                      const Color(0xFFF1F5F9),
                      const Color(0xFFE2E8F0),
                    ],
            ),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.shade300.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runAlignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 16,
            children: List.generate(displayData.length, (index) {
              final item = displayData[index];
              // Staggered size distribution (e.g. 138, 118, 102, 94, 88...)
              final baseSizes = [138.0, 118.0, 110.0, 102.0, 96.0, 92.0, 88.0, 84.0, 82.0, 80.0];
              final bubbleSize = index < baseSizes.length ? baseSizes[index] : 80.0;

              return CategoryBubbleWidget(
                data: item,
                size: bubbleSize,
                isDark: isDark,
              );
            }),
          ),
        ),
      ],
    );
  }
}

