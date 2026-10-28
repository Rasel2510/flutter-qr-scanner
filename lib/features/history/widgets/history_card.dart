import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/qr_history_item.dart';
import '../../../core/widgets/neo_box.dart';

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

  Color get _leadingColor =>
      item.mode == QRMode.generated ? AppColors.backdrop : AppColors.info;

  IconData get _modeIcon => item.mode == QRMode.generated
      ? Icons.qr_code_rounded
      : Icons.qr_code_scanner_rounded;

  String get _modeLabel =>
      item.mode == QRMode.generated ? 'Generated' : 'Scanned';

  Color get _modeBadgeColor =>
      item.mode == QRMode.generated ? AppColors.backdrop : AppColors.success;

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
      builder: (_) => _DetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      color: AppColors.surface,
      radius: 14,
      padding: 14,
      onTap: () => _showDetailSheet(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEADING ICON in colored circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _leadingColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: Icon(_modeIcon, color: AppColors.ink, size: 24),
          ),

          const SizedBox(width: 14),

          /// CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Badge(
                        text: QRHistoryItem.typeLabel(item.type),
                        color: AppColors.primary),
                    const SizedBox(width: 6),
                    _Badge(text: _modeLabel, color: _modeBadgeColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.content.length > 50
                      ? '${item.content.substring(0, 50)}...'
                      : item.content,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.ink.withValues(alpha: 0.6)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(item.timestamp,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.ink.withValues(alpha: 0.45))),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// ACTION BUTTONS
          Column(
            children: [
              _CircleBtn(
                icon: Icons.visibility_outlined,
                onTap: () => _showDetailSheet(context),
                color: AppColors.info,
              ),
              const SizedBox(height: 6),
              _CircleBtn(
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

/// ─── BADGE ────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: 0.6,
        ),
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
            Text('Copied to clipboard'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          const SizedBox(height: 20),

          /// HEADER BADGES + TIMESTAMP
          Row(
            children: [
              _Badge(
                  text: QRHistoryItem.typeLabel(item.type),
                  color: AppColors.primary),
              const SizedBox(width: 8),
              _Badge(
                text: item.mode == QRMode.generated ? 'Generated' : 'Scanned',
                color: item.mode == QRMode.generated
                    ? AppColors.backdrop
                    : AppColors.success,
              ),
              const Spacer(),
              Text(item.timestamp,
                  style: TextStyle(
                      fontSize: 11, color: AppColors.ink.withValues(alpha: 0.45))),
            ],
          ),

          const SizedBox(height: 20),

          /// QR PREVIEW (generated only)
          if (item.mode == QRMode.generated) ...[
            Center(
              child: NeoBox(
                color: Colors.white,
                radius: 16,
                padding: 16,
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
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: Text(
              item.content,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.ink,
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
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
                  Icon(Icons.copy_rounded, color: AppColors.ink, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'COPY CONTENT',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.ink),
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

/// ─── CIRCLE BUTTON ───────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CircleBtn(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Icon(icon, color: AppColors.ink, size: 15),
      ),
    );
  }
}

