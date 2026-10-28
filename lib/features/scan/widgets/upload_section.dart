// ─── UPLOAD SECTION ──────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/widgets/neo_box.dart';

class UploadSection extends StatelessWidget {
  final VoidCallback onPick;
  const UploadSection({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      color: AppColors.surface,
      radius: 16,
      padding: 0,
      onTap: onPick,
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                color: AppColors.ink,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to browse',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PNG · JPG · WEBP',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ink.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

