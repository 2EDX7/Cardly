import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom painter that draws a starry background
class StarsPainter extends CustomPainter {
  final Color starColor;
  final int numberOfStars;

  StarsPainter({
    this.starColor = Colors.white,
    this.numberOfStars = 50,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = starColor
      ..style = PaintingStyle.fill;

    // Use a fixed seed for consistent star positions
    final random = math.Random(42);

    for (int i = 0; i < numberOfStars; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5; // Stars between 0.5 and 2.5 radius
      final opacity = random.nextDouble() * 0.5 + 0.3; // Opacity between 0.3 and 0.8

      paint.color = starColor.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget that provides a starry background
class StarsBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color starColor;
  final int numberOfStars;

  const StarsBackground({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.starColor = Colors.white,
    this.numberOfStars = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background color
        Container(color: backgroundColor),
        // Stars layer
        CustomPaint(
          painter: StarsPainter(
            starColor: starColor,
            numberOfStars: numberOfStars,
          ),
          child: Container(),
        ),
        // Content
        child,
      ],
    );
  }
}