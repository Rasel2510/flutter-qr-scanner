import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/neo_box.dart';

class QRPreviewWidget extends StatefulWidget {
  final String content;
  final Color fgColor;
  final Color bgColor;
  final double size;
  final String ecLevel;

  const QRPreviewWidget({
    super.key,
    required this.content,
    required this.fgColor,
    required this.bgColor,
    required this.size,
    required this.ecLevel,
  });

  @override
  State<QRPreviewWidget> createState() => _QRPreviewWidgetState();
}

class _QRPreviewWidgetState extends State<QRPreviewWidget> {
  final GlobalKey _qrKey = GlobalKey();

  int get _ecLevel {
    switch (widget.ecLevel) {
      case 'L':
        return QrErrorCorrectLevel.L;
      case 'Q':
        return QrErrorCorrectLevel.Q;
      case 'H':
        return QrErrorCorrectLevel.H;
      default:
        return QrErrorCorrectLevel.M;
    }
  }

  Future<Uint8List?> _captureQR() async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio * 2,
      );
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('QR Capture Error: $e');
      return null;
    }
  }

  Future<void> _downloadQR() async {
    final bytes = await _captureQR();
    if (bytes == null) return;

    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              _snackBar('Gallery permission denied', Icons.error_outline),
            );
          }
          return;
        }
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/qrcraft_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);
      await Gal.putImage(path, album: 'QRcraft');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Saved to gallery!', Icons.check_circle_rounded),
        );
      }
    } catch (e) {
      debugPrint('Save Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Could not save to gallery', Icons.error_outline),
        );
      }
    }
  }

  Future<void> _shareQR() async {
    final bytes = await _captureQR();
    if (bytes == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qrcraft_share.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR Code generated with QRcraft',
      );
    } catch (e) {
      debugPrint('Share Error: $e');
    }
  }

  Future<void> _copyQR() async {
    await Clipboard.setData(ClipboardData(text: widget.content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Copied to clipboard!', Icons.copy_rounded),
      );
    }
  }

  SnackBar _snackBar(String msg, IconData icon) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(msg),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      color: AppColors.surface,
      radius: 14,
      padding: 0,
      child: Column(
        children: [
          /// QR CODE
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Center(
              child: RepaintBoundary(
                key: _qrKey,
                child: NeoBox(
                  color: widget.bgColor,
                  radius: 14,
                  padding: 16,
                  child: QrImageView(
                    data:
                        widget.content.isEmpty ? ' ' : widget.content,
                    version: QrVersions.auto,
                    size: widget.size,
                    padding: EdgeInsets.zero,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: widget.fgColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: widget.fgColor,
                    ),
                    errorCorrectionLevel: _ecLevel,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// CONTENT PREVIEW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: Text(
                widget.content.length > 60
                    ? '${widget.content.substring(0, 60)}...'
                    : widget.content,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.ink.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// ACTION BUTTONS — three NeoBox buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                _ActionBtn(
                  icon: Icons.download_rounded,
                  label: 'Save',
                  onTap: _downloadQR,
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                _ActionBtn(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: _copyQR,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                _ActionBtn(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: _shareQR,
                  color: AppColors.info,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.ink,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: AppColors.ink),
              const SizedBox(height: 5),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

