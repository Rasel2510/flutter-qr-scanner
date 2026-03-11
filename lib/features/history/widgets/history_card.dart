import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/qr_history_item.dart';
import '../../../shared/widgets/app_widgets.dart';

class HistoryCard extends StatelessWidget {
  final QRHistoryItem item;
  final VoidCallback onDelete;
  final VoidCallback onReload;

  const HistoryCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onReload,
  });

  Color get _modeColor => item.mode == QRMode.generated ? AppColors.primary : AppColors.success;
  String get _modeLabel => item.mode == QRMode.generated ? 'Generated' : 'Scanned';

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// QR THUMBNAIL
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.mode == QRMode.generated
                  ? QrImageView(
                      data: item.content,
                      version: QrVersions.auto,
                      size: 64,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                    )
                  : Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 32),
                    ),
            ),
          ),

          const SizedBox(width: 14),

          /// CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBadge(text: QRHistoryItem.typeLabel(item.type), color: AppColors.primary),
                    const SizedBox(width: 6),
                    AppBadge(text: _modeLabel, color: _modeColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.content.length > 50 ? '${item.content.substring(0, 50)}...' : item.content,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(item.timestamp, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// ACTIONS
          Column(
            children: [
              _IconBtn(icon: Icons.refresh_rounded, onTap: onReload, color: AppColors.primary),
              const SizedBox(height: 6),
              _IconBtn(icon: Icons.delete_outline_rounded, onTap: onDelete, color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _IconBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}
