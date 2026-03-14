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

  /// Capture QR as PNG
  Future<Uint8List?> _captureQR() async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      final image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio * 2,
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("QR Capture Error: $e");
      return null;
    }
  }

  /// Save QR to device
Future<void> _downloadQR() async {
    final bytes = await _captureQR();
    if (bytes == null) return;

    try {
      // Check / request gallery permission
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              _snackBar('Gallery permission denied', AppColors.error),
            );
          }
          return;
        }
      }

      // Write to temp file then save to gallery
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/qrcraft_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);

      await Gal.putImage(path, album: 'QRcraft');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Saved to gallery!', AppColors.success),
        );
      }
    } catch (e) {
      debugPrint("Save Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Could not save to gallery', AppColors.error),
        );
      }
    }
  }

  /// Share QR
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
      debugPrint("Share Error: $e");
    }
  }

  /// Copy content to clipboard
  Future<void> _copyQR() async {
    await Clipboard.setData(
      ClipboardData(text: widget.content),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Copied to clipboard!', AppColors.primary),
      );
    }
  }

  SnackBar _snackBar(String msg, Color color) {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            msg,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          /// QR CODE
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Center(
              child: RepaintBoundary(
                key: _qrKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.bgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: widget.content.isEmpty ? " " : widget.content,
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.content.length > 60
                    ? '${widget.content.substring(0, 60)}...'
                    : widget.content,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// ACTION BUTTONS
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                _ActionBtn(
                  icon: Icons.download_rounded,
                  label: 'Save',
                  onTap: _downloadQR,
                ),
                const SizedBox(width: 10),
                _ActionBtn(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: _copyQR,
                ),
                const SizedBox(width: 10),
                _ActionBtn(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: _shareQR,
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

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.text,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
