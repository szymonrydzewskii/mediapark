import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;

  DashedBorderPainter({
    required this.color,
    double? strokeWidth,
    double? gap,
    double? dashLength,
  }) : strokeWidth = (strokeWidth ?? 1).w,
       gap = (gap ?? 20).w,
       dashLength = (dashLength ?? 20).w;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addOval(rect);
    final dashedPath = _createDashedPath(path);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0, metric.length).toDouble();
        dest.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashLength + gap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
