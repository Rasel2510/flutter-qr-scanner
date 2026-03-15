import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Color get _modeColor =>
      item.mode == QRMode.generated ? AppColors.orange : AppColors.success;
  String get _modeLabel =>
      item.mode == QRMode.generated ? 'Generated' : 'Scanned';
  IconData get _modeIcon => item.mode == QRMode.generated
      ? Icons.qr_code_rounded
      : Icons.qr_code_scanner_rounded;

  /// ─── BOTTOM SHEET ────────────────────────────────────────
  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// QR THUMBNAIL
          Container(
            width: 64,
            height: 64,
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
                      eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black),
                    )
                  : Container(
                      color: AppColors.surface,
                      child:
                          Icon(_modeIcon, color: AppColors.primary, size: 32),
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
                    AppBadge(
                        text: QRHistoryItem.typeLabel(item.type),
                        color: AppColors.primary),
                    const SizedBox(width: 6),
                    AppBadge(text: _modeLabel, color: _modeColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.content.length > 50
                      ? '${item.content.substring(0, 50)}...'
                      : item.content,
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(item.timestamp,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// ACTIONS
          Column(
            children: [
              /// 👇 open bottom sheet instead of onReload
              _IconBtn(
                icon: Icons.visibility_outlined,
                onTap: () => _showDetailSheet(context),
                color: AppColors.primary,
              ),
              const SizedBox(height: 6),
              _IconBtn(
                icon: Icons.delete_outline_rounded,
                onTap: onDelete,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ─── DETAIL BOTTOM SHEET ─────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final QRHistoryItem item;

  const _DetailSheet({required this.item});

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: item.content));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 16),
            SizedBox(width: 8),
            Text('Copied to clipboard',
                style: TextStyle(color: AppColors.text)),
          ],
        ),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// HANDLE
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          const SizedBox(height: 20),

          /// HEADER
          Row(
            children: [
              AppBadge(
                  text: QRHistoryItem.typeLabel(item.type),
                  color: AppColors.primary),
              const SizedBox(width: 8),
              AppBadge(
                text: item.mode == QRMode.generated ? 'Generated' : 'Scanned',
                color: item.mode == QRMode.generated
                    ? AppColors.primary
                    : AppColors.success,
              ),
              const Spacer(),
              Text(item.timestamp,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),

          const SizedBox(height: 20),

          /// QR CODE — only for generated
          if (item.mode == QRMode.generated) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: item.content,
                  version: QrVersions.auto,
                  size: 200,
                  eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          /// CONTENT BOX
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              item.content,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// COPY BUTTON
          GestureDetector(
            onTap: () => _copy(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Copy Content',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── ICON BUTTON ─────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _IconBtn(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
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
