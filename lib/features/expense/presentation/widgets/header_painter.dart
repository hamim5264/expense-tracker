import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/theme_service.dart';

class HeaderPainter extends CustomPainter {
  final Color? color;

  HeaderPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveColor = color ?? ThemeService.primaryColorNotifier.value;
    Paint paint = Paint()
      ..color = effectiveColor
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HeaderPainter oldDelegate) =>
      oldDelegate.color != color;
}
