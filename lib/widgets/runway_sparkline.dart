import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/forecast.dart';

/// A small projected-balance line for the runway card.
class RunwaySparkline extends StatelessWidget {
  const RunwaySparkline({
    super.key,
    required this.points,
    required this.color,
    this.height = 84,
  });

  final List<ForecastPoint> points;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          points: points,
          color: color,
          gridColor: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.points,
    required this.color,
    required this.gridColor,
  });

  final List<ForecastPoint> points;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Draw the zero line so "running out" is visually obvious.
    final balances = points.map((point) => point.balanceCents).toList();
    final maxValue = balances.isEmpty
        ? 1
        : math.max(1, balances.reduce(math.max));
    final minValue = balances.isEmpty
        ? 0
        : math.min(0, balances.reduce(math.min));
    final range = math.max(1, maxValue - minValue);

    double xFor(int index) {
      if (points.length <= 1) return 0;
      return size.width * index / (points.length - 1);
    }

    double yFor(int value) =>
        size.height - ((value - minValue) / range) * size.height;

    final zeroY = yFor(0).clamp(0.0, size.height);
    final zeroPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    _drawDashedLine(
      canvas,
      Offset(0, zeroY),
      Offset(size.width, zeroY),
      zeroPaint,
    );

    if (points.isEmpty) return;

    final path = Path()..moveTo(xFor(0), yFor(balances.first));
    for (var i = 1; i < points.length; i++) {
      path.lineTo(xFor(i), yFor(balances[i]));
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (points.length > 1) {
      final last = Offset(xFor(points.length - 1), yFor(balances.last));
      canvas.drawCircle(last, 4, Paint()..color = color);
      canvas.drawCircle(last, 2, Paint()..color = Colors.white);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 4.0;
    const gap = 5.0;
    var x = start.dx;
    while (x < end.dx) {
      canvas.drawLine(
        Offset(x, start.dy),
        Offset(math.min(x + dash, end.dx), end.dy),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.gridColor != gridColor;
}
