// ─── CAMERA SECTION ──────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/widgets/scan_frame.dart';

class CameraSection extends StatelessWidget {
  final MobileScannerController controller;
  final bool torchOn;
  final void Function(BarcodeCapture) onDetect;
  final VoidCallback onToggleTorch;
  final VoidCallback onPickGallery;

  const CameraSection({
    super.key,
    required this.controller,
    required this.torchOn,
    required this.onDetect,
    required this.onToggleTorch,
    required this.onPickGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Camera preview with ink border & neo shadow
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.ink, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ink,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 320,
            child: Stack(fit: StackFit.expand, children: [
              MobileScanner(controller: controller, onDetect: onDetect),
              // New ScanFrame overlay with animated scan line
              const ScanFrame(frameSize: 220),
              // Torch toggle button
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: onToggleTorch,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: torchOn
                          ? AppColors.primary
                          : Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 2),
                    ),
                    child: Icon(
                      torchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 14),
      // Pick from gallery button
      GestureDetector(
        onTap: onPickGallery,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.ink,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined, color: AppColors.ink, size: 18),
              SizedBox(width: 8),
              Text(
                'Pick from Gallery',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

