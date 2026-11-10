
import 'package:flutter/material.dart';

class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  const DottedBorderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(8),
        child: Center(child: child),
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 3;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Path path = Path()..addRect(rect); // No rounded corners

    final Path dashedPath = Path();

    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
