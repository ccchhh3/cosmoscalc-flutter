import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpaceBackgroundPainter extends CustomPainter {
  static final List<_Star> _stars = _generateStars();

  static List<_Star> _generateStars() {
    final rng = math.Random(42);
    return List.generate(80, (_) => _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      opacity: 0.1 + rng.nextDouble() * 0.5,
      radius: 0.5 + rng.nextDouble() * 1.0,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Base background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF040509),
    );

    // Blue bloom — top-left
    _drawBloom(
      canvas, size,
      cx: 0, cy: 0,
      radius: size.width * 0.85,
      color: const Color(0xFF2E5AFF),
      opacity: 0.28,
    );

    // Cyan bloom — bottom-right
    _drawBloom(
      canvas, size,
      cx: size.width, cy: size.height,
      radius: size.width * 0.70,
      color: const Color(0xFF3EFFB4),
      opacity: 0.12,
    );

    // Violet bloom — center-right
    _drawBloom(
      canvas, size,
      cx: size.width * 0.85, cy: size.height * 0.40,
      radius: size.width * 0.55,
      color: const Color(0xFF8C50FF),
      opacity: 0.14,
    );

    // Stars
    final starPaint = Paint();
    for (final star in _stars) {
      starPaint.color = Colors.white.withOpacity(star.opacity);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        starPaint,
      );
    }
  }

  void _drawBloom(
    Canvas canvas,
    Size size, {
    required double cx,
    required double cy,
    required double radius,
    required Color color,
    required double opacity,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(opacity),
          color.withOpacity(0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant SpaceBackgroundPainter oldDelegate) => false;
}

class _Star {
  final double x, y, opacity, radius;
  const _Star({
    required this.x, required this.y,
    required this.opacity, required this.radius,
  });
}
