import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    super.key,
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedLinePainter(
        color: color,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
      size: Size.infinite,
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
