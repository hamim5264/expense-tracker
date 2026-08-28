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

    const double cornerRadius = 32.0;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - cornerRadius);
    path.quadraticBezierTo(0, size.height, cornerRadius, size.height);
    path.lineTo(size.width - cornerRadius, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - cornerRadius);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HeaderPainter oldDelegate) =>
      oldDelegate.color != color;
}
