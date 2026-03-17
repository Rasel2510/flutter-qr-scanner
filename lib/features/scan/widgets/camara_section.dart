// ─── CAMERA SECTION ──────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/features/scan/widgets/scanframe_painter.dart';

class CameraSection extends StatelessWidget {
  final MobileScannerController controller;
  final bool torchOn;
  final void Function(BarcodeCapture) onDetect;
  final VoidCallback onToggleTorch;
  final VoidCallback onPickGallery;
  const CameraSection(
      {super.key, required this.controller,
      required this.torchOn,
      required this.onDetect,
      required this.onToggleTorch,
      required this.onPickGallery});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 320,
          child: Stack(fit: StackFit.expand, children: [
            MobileScanner(controller: controller, onDetect: onDetect),
            const ScanOverlay(),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onToggleTorch,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: torchOn ? AppColors.warning : Colors.black38,
                      shape: BoxShape.circle),
                  child: Icon(
                      torchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: Colors.white,
                      size: 20),
                ),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: onPickGallery,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child:
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.photo_library_outlined, color: AppColors.text, size: 18),
            SizedBox(width: 8),
            Text('Pick from Gallery',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text)),
          ]),
        ),
      ),
    ]);
  }
}

// ─── SCAN OVERLAY ────────────────────────────────────────
class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: ScanFramePainter());
}
