 

import 'package:flutter/material.dart';

class ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const frameSize = 200.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - frameSize / 2;
    final top = cy - frameSize / 2;
    final right = cx + frameSize / 2;
    final bottom = cy + frameSize / 2;

    // Dim overlay outside frame
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.38);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), dimPaint);
    canvas.drawRect(
        Rect.fromLTRB(0, bottom, size.width, size.height), dimPaint);
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), dimPaint);
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), dimPaint);

    // Corner brackets
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cl = 28.0; // corner length
    const r = 6.0; // corner radius

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(left, top + cl)
          ..lineTo(left, top + r)
          ..arcToPoint(Offset(left + r, top), radius: const Radius.circular(r))
          ..lineTo(left + cl, top),
        paint);
    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(right - cl, top)
          ..lineTo(right - r, top)
          ..arcToPoint(Offset(right, top + r), radius: const Radius.circular(r))
          ..lineTo(right, top + cl),
        paint);
    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(left, bottom - cl)
          ..lineTo(left, bottom - r)
          ..arcToPoint(Offset(left + r, bottom),
              radius: const Radius.circular(r))
          ..lineTo(left + cl, bottom),
        paint);
    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(right, bottom - cl)
          ..lineTo(right, bottom - r)
          ..arcToPoint(Offset(right - r, bottom),
              radius: const Radius.circular(r), clockwise: false)
          ..lineTo(right - cl, bottom),
        paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
