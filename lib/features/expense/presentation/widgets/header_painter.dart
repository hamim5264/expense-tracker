import 'package:flutter/material.dart';

class HeaderPainter extends CustomPainter {
  final Color color;

  HeaderPainter({this.color = const Color(0xFF4F378A)});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
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
