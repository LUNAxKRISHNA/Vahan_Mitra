import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class SubtleRouteBackground extends StatefulWidget {
  final Widget child;

  const SubtleRouteBackground({super.key, required this.child});

  @override
  State<SubtleRouteBackground> createState() => _SubtleRouteBackgroundState();
}

class _SubtleRouteBackgroundState extends State<SubtleRouteBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _RoutePainter(animationValue: _controller.value),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final double animationValue;

  // Cached path metrics — computed once per unique size, not every frame
  static Size? _cachedSize;
  static List<PathMetric>? _cachedMetrics;

  _RoutePainter({required this.animationValue});

  List<PathMetric> _getPathMetrics(Size size) {
    // Only recompute when the canvas size changes (e.g., orientation change)
    if (_cachedSize == size && _cachedMetrics != null) {
      return _cachedMetrics!;
    }

    final path1 = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.4,
        size.width,
        size.height * 0.1,
      );

    final path2 = Path()
      ..moveTo(size.width * 0.2, size.height)
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.6,
        size.width,
        size.height * 0.8,
      );

    final path3 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.9,
        size.width * 0.9,
        size.height,
      );

    final combined = Path()
      ..addPath(path1, Offset.zero)
      ..addPath(path2, Offset.zero)
      ..addPath(path3, Offset.zero);

    _cachedSize = size;
    _cachedMetrics = combined.computeMetrics().toList();
    return _cachedMetrics!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD8DEE9).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final double dashWidth = 8.0;
    final double dashSpace = 8.0;
    final double totalDashLength = dashWidth + dashSpace;
    final double startOffset = animationValue * totalDashLength;

    // Use cached metrics — no computeMetrics() call on every frame
    final metrics = _getPathMetrics(size);

    for (final pathMetric in metrics) {
      double distance = -startOffset;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (distance + length > 0) {
          final double start = math.max(0.0, distance);
          final double end =
              math.min(pathMetric.length, distance + length);
          canvas.drawPath(pathMetric.extractPath(start, end), paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
