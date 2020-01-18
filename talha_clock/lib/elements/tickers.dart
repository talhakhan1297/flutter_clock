import 'package:flutter/material.dart';
import 'dart:math';

class TickerPainter extends CustomPainter {
  DateTime datetime;
  final bool showTicks;
  final Color tickColor;

  static const double BASE_SIZE = 320.0;
  static const double MINUTES_IN_HOUR = 60.0;
  static const double SECONDS_IN_MINUTE = 60.0;
  static const double HOURS_IN_CLOCK = 12.0;
  static const double HAND_PIN_HOLE_SIZE = 8.0;
  static const double STROKE_WIDTH = 3.0;

  TickerPainter({
    @required this.datetime,
    this.showTicks = true,
    this.tickColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scaleFactor = size.shortestSide / BASE_SIZE;

    if (showTicks) _paintTickMarks(canvas, size, scaleFactor);
  }

  // ref: https://www.codenameone.com/blog/codename-one-graphics-part-2-drawing-an-analog-clock.html
  void _paintTickMarks(Canvas canvas, Size size, double scaleFactor) {
    double r = size.shortestSide / 2;
    double tick = 10 * scaleFactor, longTick = 20 * scaleFactor;
    double p = longTick + 4 * scaleFactor;
    Paint tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2.0 * scaleFactor;

    for (double i = 1; i <= 60; i = i + 0.5) {
      // default tick length is short
      double len = 0;
      if (i % 5 == 0) {
        // Longest tick on quarters (every 5 ticks)
        len = longTick;
      } else if (i % 2.5 == 0) {
        // Medium ticks on the '5's (every 5 ticks)
        len = tick;
      }
      // Get the angle from 12 O'Clock to this tick (radians)
      double angleFrom12 = i / 60.0 * 2.0 * pi;

      // Get the angle from 3 O'Clock to this tick
      // Note: 3 O'Clock corresponds with zero angle in unit circle
      // Makes it easier to do the math.
      double angleFrom3 = pi / 2.0 - angleFrom12;

      canvas.drawLine(
        size.center(
          Offset(
            cos(angleFrom3) * (r + len - p),
            sin(angleFrom3) * (r + len - p),
          ),
        ),
        size.center(
          Offset(
            cos(angleFrom3) * (r - p),
            sin(angleFrom3) * (r - p),
          ),
        ),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(TickerPainter oldDelegate) {
    return oldDelegate?.datetime?.isBefore(datetime) ?? true;
  }
}
