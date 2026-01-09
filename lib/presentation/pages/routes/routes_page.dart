import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/config_service.dart';

class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = ConfigService().routes;
    final primaryColor = Color(ConfigService().getColor('primary_color'));
    final backgroundColor = Color(ConfigService().getColor('secondary_color'));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Bus Routes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return _RouteCard(
            routeData: route,
            primaryColor: primaryColor,
            backgroundColor: backgroundColor,
          );
        },
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final Map<String, dynamic> routeData;
  final Color primaryColor;
  final Color backgroundColor;

  const _RouteCard({
    required this.routeData,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> stops = routeData['stops'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.route, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeData['name'] ?? 'Unknown Route',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (routeData['timings'] != null)
                        Text(
                          routeData['timings'],
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomPaint(
              size: Size(double.infinity, stops.length * 60.0),
              painter: _TimelinePainter(stops: stops, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final List<dynamic> stops;
  final Color color;

  _TimelinePainter({required this.stops, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine =
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    final paintDot =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final paintText = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    const double startX = 20.0;
    const double itemHeight = 60.0;

    // Draw connecting line
    if (stops.length > 1) {
      canvas.drawLine(
        const Offset(startX, 10),
        Offset(startX, (stops.length - 1) * itemHeight + 10),
        paintLine,
      );
    }

    for (int i = 0; i < stops.length; i++) {
      final double y = i * itemHeight + 10.0;
      final Offset center = Offset(startX, y);

      // Draw dot
      canvas.drawCircle(center, 8, paintDot);

      // Draw inner white dot for style
      canvas.drawCircle(center, 3, Paint()..color = Colors.white);

      // Draw text
      paintText.text = TextSpan(
        text: stops[i].toString(),
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      );
      paintText.layout(maxWidth: size.width - 50);
      paintText.paint(canvas, Offset(startX + 30, y - paintText.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
