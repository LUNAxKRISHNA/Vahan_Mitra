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

  _RoutePainter({required this.animationValue});

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

    void drawDashedPath(Path path) {
      PathMetrics pathMetrics = path.computeMetrics();
      for (PathMetric pathMetric in pathMetrics) {
        double distance = -startOffset;
        bool draw = true;
        while (distance < pathMetric.length) {
          double length = draw ? dashWidth : dashSpace;
          if (distance + length > 0) {
            double start = math.max(0.0, distance);
            double end = math.min(pathMetric.length, distance + length);
            canvas.drawPath(pathMetric.extractPath(start, end), paint);
          }
          distance += length;
          draw = !draw;
        }
      }
    }

    // Path 1
    Path path1 = Path();
    path1.moveTo(0, size.height * 0.2);
    path1.quadraticBezierTo(
        size.width * 0.5, size.height * 0.4, size.width, size.height * 0.1);
    drawDashedPath(path1);

    // Path 2
    Path path2 = Path();
    path2.moveTo(size.width * 0.2, size.height);
    path2.quadraticBezierTo(
        size.width * 0.8, size.height * 0.6, size.width, size.height * 0.8);
    drawDashedPath(path2);

    // Path 3
    Path path3 = Path();
    path3.moveTo(0, size.height * 0.7);
    path3.quadraticBezierTo(
        size.width * 0.4, size.height * 0.9, size.width * 0.9, size.height);
    drawDashedPath(path3);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
