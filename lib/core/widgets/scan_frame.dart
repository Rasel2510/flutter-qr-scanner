import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Scanner overlay: dark mask, four rounded corner brackets (ink + white
/// outer stroke), and an animated yellow scan line.
class ScanFrame extends StatefulWidget {
  final double frameSize;
  const ScanFrame({super.key, this.frameSize = 250});

  @override
  State<ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends State<ScanFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(animation: _ctrl, frameSize: widget.frameSize),
      child: const SizedBox.expand(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _FramePainter extends CustomPainter {
  final Animation<double> animation;
  final double frameSize;

  _FramePainter({required this.animation, required this.frameSize})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = frameSize / 2;
    final l = cx - half;
    final t = cy - half;
    final r = cx + half;
    final b = cy + half;

    // ── Dark overlay (50 % black) ───────────────────────────
    final dim = Paint()..color = const Color(0x80000000);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, t), dim);
    canvas.drawRect(Rect.fromLTRB(0, b, size.width, size.height), dim);
    canvas.drawRect(Rect.fromLTRB(0, t, l, b), dim);
    canvas.drawRect(Rect.fromLTRB(r, t, size.width, b), dim);

    const cl = 32.0; // corner bracket length
    const cr = 8.0; // corner radius

    // ── White outer stroke (2 px visual border) ─────────────
    final white = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawCorners(canvas, l, t, r, b, cl, cr, white);

    // ── Ink inner stroke ────────────────────────────────────
    final ink = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawCorners(canvas, l, t, r, b, cl, cr, ink);

    // ── Yellow scan line ────────────────────────────────────
    final lineY = t + 14 + (b - t - 28) * animation.value;
    final scanPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2;
    canvas.drawLine(Offset(l + 14, lineY), Offset(r - 14, lineY), scanPaint);
  }

  void _drawCorners(Canvas canvas, double l, double t, double r, double b,
      double cl, double cr, Paint paint) {
    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(l, t + cl)
        ..lineTo(l, t + cr)
        ..arcToPoint(Offset(l + cr, t), radius: Radius.circular(cr))
        ..lineTo(l + cl, t),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(r - cl, t)
        ..lineTo(r - cr, t)
        ..arcToPoint(Offset(r, t + cr), radius: Radius.circular(cr))
        ..lineTo(r, t + cl),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(l, b - cl)
        ..lineTo(l, b - cr)
        ..arcToPoint(Offset(l + cr, b), radius: Radius.circular(cr))
        ..lineTo(l + cl, b),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(r, b - cl)
        ..lineTo(r, b - cr)
        ..arcToPoint(Offset(r - cr, b),
            radius: Radius.circular(cr), clockwise: false)
        ..lineTo(r - cl, b),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) => true;
}

