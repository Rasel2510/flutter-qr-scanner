// ─── UPLOAD SECTION ──────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:qrcraft/core/theme/app_theme.dart';

class UploadSection extends StatelessWidget {
  final VoidCallback onPick;
  const UploadSection({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
        child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_rounded,
                  color: AppColors.textMuted, size: 36),
              SizedBox(height: 14),
              Text('Tap to browse',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text)),
              SizedBox(height: 4),
              Text('PNG · JPG · WEBP',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ]),
      ),
    );
  }
}
