import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportsHeaderWidget extends StatelessWidget {
  final int reportsCount;
  final VoidCallback onBack;
  final VoidCallback onDeleteAll;

  const ReportsHeaderWidget({
    super.key,
    required this.reportsCount,
    required this.onBack,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7546B5),
            Color(0xFF54338D),
            Color(0xFF40266F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(38),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          child: Column(
            children: [
              // Top Action Bar
              Row(
                children: [
                  _buildCircularButton(
                    icon: CupertinoIcons.back,
                    onTap: onBack,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense Reports',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Financial statements & exports',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE0D2F5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCircularButton(
                    icon: CupertinoIcons.trash,
                    tooltip: 'Clear all reports',
                    onTap: onDeleteAll,
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Banner Card & 3D Financial Document Illustration
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              CupertinoIcons.doc_text,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$reportsCount Report${reportsCount == 1 ? '' : 's'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Total generated',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFFDCCCF3),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 3D Report & Donut Chart Graphic
                  const _Reports3DGraphic(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }
}

/// Stylized 3D Document with mini bar chart & donut pie chart
class _Reports3DGraphic extends StatelessWidget {
  const _Reports3DGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background sheet (tilted counter-clockwise)
          Positioned(
            left: 2,
            top: 4,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 66,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

          // Foreground main sheet (tilted clockwise)
          Positioned(
            right: 2,
            child: Transform.rotate(
              angle: 0.08,
              child: Container(
                width: 70,
                height: 84,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.24),
                      blurRadius: 18,
                      offset: const Offset(2, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top header line
                    Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B4BD1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Mini Bar Chart
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar(8, const Color(0xFF9E6BE6)),
                        const SizedBox(width: 3),
                        _buildBar(15, const Color(0xFF673AB7)),
                        const SizedBox(width: 3),
                        _buildBar(11, const Color(0xFF8B4BD1)),
                        const SizedBox(width: 3),
                        _buildBar(18, const Color(0xFF512DA8)),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Horizontal placeholder text lines
                    Container(
                      width: 30,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2D9F3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 2.5),
                    Container(
                      width: 18,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2D9F3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const Spacer(),

                    // Donut Chart Graphic at bottom right
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CustomPaint(
                          painter: _DonutChartPainter(),
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
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 4.5,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2.2;

    final paintPurple = Paint()
      ..color = const Color(0xFF673AB7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final paintPink = Paint()
      ..color = const Color(0xFFFF5263)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Pink arc: ~110 degrees
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.2,
      1.8,
      false,
      paintPink,
    );

    // Purple arc: remainder ~220 degrees
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.9,
      3.8,
      false,
      paintPurple,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
