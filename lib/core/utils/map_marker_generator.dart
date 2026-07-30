import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerGenerator {
  static Future<BitmapDescriptor> createBusMarker({
    required Color color,
    String? label,
    double pinSize = 50,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // 1. Measure Label if present
    TextPainter? labelPainter;
    double pillWidth = 0;
    double pillHeight = 0;
    const double gap = 4.0;

    if (label != null && label.isNotEmpty) {
      labelPainter = TextPainter(textDirection: TextDirection.ltr);
      labelPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      );
      labelPainter.layout();
      pillWidth = labelPainter.width + 14;
      pillHeight = labelPainter.height + 6;
    }

    final double canvasWidth = math.max(pinSize, pillWidth + 8);
    final double canvasHeight =
        (labelPainter != null ? (pillHeight + gap) : 0) + pinSize;
    final double cx = canvasWidth / 2;

    // 2. Draw Floating Label Pill (if label is provided)
    if (labelPainter != null) {
      final Rect pillRect = Rect.fromLTWH(
        cx - (pillWidth / 2),
        2,
        pillWidth,
        pillHeight,
      );
      final RRect pillRRect = RRect.fromRectAndRadius(
        pillRect,
        Radius.circular(pillHeight / 2),
      );

      // Pill Shadow
      final Paint pillShadow =
          Paint()
            ..color = Colors.black.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(pillRRect.shift(const Offset(0, 2)), pillShadow);

      // Pill Background
      final Paint pillBg =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
      canvas.drawRRect(pillRRect, pillBg);

      // Pill Border
      final Paint pillBorder =
          Paint()
            ..color = color.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2;
      canvas.drawRRect(pillRRect, pillBorder);

      // Label Text
      labelPainter.paint(
        canvas,
        Offset(
          cx - (labelPainter.width / 2),
          2 + (pillHeight - labelPainter.height) / 2,
        ),
      );
    }

    // 3. Draw Location Pin below label
    final double pinOffsetY = labelPainter != null ? (pillHeight + gap) : 0;
    final double radius = pinSize * 0.28;
    final double topY = pinOffsetY + (pinSize * 0.10) + radius;
    final double bottomY = pinOffsetY + (pinSize * 0.88);

    final double dy = bottomY - topY;
    final double alpha = math.asin(radius / dy);

    final Path pinPath = Path();
    pinPath.arcTo(
      Rect.fromCircle(center: Offset(cx, topY), radius: radius),
      (math.pi / 2) + alpha,
      (2 * math.pi) - (2 * alpha),
      false,
    );
    pinPath.lineTo(cx, bottomY);
    pinPath.close();

    // Pin Drop Shadow
    final Paint shadowPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(pinPath.shift(const Offset(0, 2)), shadowPaint);

    // Main Pin Body
    final Paint pinPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, pinPaint);

    // White Pin Border
    final Paint strokePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
    canvas.drawPath(pinPath, strokePaint);

    // White Inner Circle for Icon
    final double innerRadius = radius * 0.70;
    final Offset headCenter = Offset(cx, topY);
    final Paint whiteCirclePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    canvas.drawCircle(headCenter, innerRadius, whiteCirclePaint);

    // Bus Icon
    TextPainter iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(Icons.directions_bus_rounded.codePoint),
      style: TextStyle(
        fontSize: innerRadius * 1.35,
        fontFamily: Icons.directions_bus_rounded.fontFamily,
        package: Icons.directions_bus_rounded.fontPackage,
        color: color,
      ),
    );
    iconPainter.layout();

    final Offset iconOffset = Offset(
      headCenter.dx - (iconPainter.width / 2),
      headCenter.dy - (iconPainter.height / 2),
    );
    iconPainter.paint(canvas, iconOffset);

    // 4. Export to Image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8List);
  }
}
