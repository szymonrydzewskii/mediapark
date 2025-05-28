import 'dart:ui';

import 'package:flutter/material.dart';

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.gap = 20,
    this.dashLength = 25,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.width / 2;
    final path = Path()..addOval(rect);

    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final Path dest = Path();
    for (PathMetric pathMetric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dest.addPath(
          pathMetric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
