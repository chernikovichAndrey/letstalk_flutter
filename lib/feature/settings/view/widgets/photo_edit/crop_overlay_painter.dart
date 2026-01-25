import 'package:flutter/material.dart';

class CropOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width < size.height ? size.width / 2 : size.height / 2;
    final radius = baseRadius * 0.8; // Reduce by 20%

    // Create path with hole in the middle
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    // Draw semi-transparent black overlay with circular cutout
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6);

    canvas.drawPath(path, overlayPaint);

    // Draw white circle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
