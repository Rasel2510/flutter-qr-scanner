import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/qr_history_item.dart';

class ScanResultWidget extends StatelessWidget {
  final String result;
  final VoidCallback onDismiss;

  const ScanResultWidget({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  QRType get _type => QRHistoryItem.detectType(result);

  String get _typeLabel => QRHistoryItem.typeLabel(_type);

  bool get _isOpenable =>
      _type == QRType.url || _type == QRType.email || _type == QRType.phone;

  String get _actionLabel {
    switch (_type) {
      case QRType.url:
        return 'Open Link';
      case QRType.email:
        return 'Send Email';
      case QRType.phone:
        return 'Call';
      default:
        return 'Open';
    }
  }

  /// COPY RESULT
  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: result));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: AppColors.success, size: 16),
            SizedBox(width: 8),
            Text('Copied to clipboard', style: TextStyle(color: Colors.black)),
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

  // /// OPEN RESULT
  // Future<void> _openResult(BuildContext context) async {
  //   final text = result.trim();
  //   Uri uri;

  //   switch (_type) {
  //     case QRType.url:
  //       final parsed = Uri.tryParse(text);

  //       if (parsed != null && parsed.hasScheme) {
  //         uri = parsed;
  //       } else {
  //         uri = Uri.parse('https://$text');
  //       }
  //       break;

  //     case QRType.email:
  //       uri = Uri(
  //         scheme: 'mailto',
  //         path: text,
  //       );
  //       break;

  //     case QRType.phone:
  //       uri = Uri(
  //         scheme: 'tel',
  //         path: text,
  //       );
  //       break;

  //     default:
  //       uri = Uri.tryParse(text) ?? Uri.parse('https://$text');
  //   }

  //   final bool appExists = await canLaunchUrl(uri);

  //   if (appExists) {
  //     /// Open in native app (browser, dialer, mail app)
  //     await launchUrl(
  //       uri,
  //       mode: LaunchMode.externalApplication,
  //     );
  //   } else {
  //     /// Fallback open inside app browser
  //     final fallback = Uri.parse('https://$text');

  //     await launchUrl(
  //       fallback,
  //       mode: LaunchMode.inAppBrowserView,
  //     );
  //   }
  // }
Future<void> _openResult(BuildContext context) async {
    final text = result.trim();
    Uri uri;

    switch (_type) {
      case QRType.url:
        final parsed = Uri.tryParse(text);
        if (parsed != null && parsed.hasScheme) {
          uri = parsed;
        } else {
          uri = Uri.parse('https://$text');
        }
        break;

      case QRType.email:
        // strip mailto: if already present
        final email =
            text.toLowerCase().startsWith('mailto:') ? text.substring(7) : text;
        uri = Uri(scheme: 'mailto', path: email.trim());
        break;

      case QRType.phone:
        // strip tel: if already present 
        final phone =
            text.toLowerCase().startsWith('tel:') ? text.substring(4) : text;
        uri = Uri(scheme: 'tel', path: phone.trim());
        break;

      default:
        uri = Uri.tryParse(text) ?? Uri.parse('https://$text');
    }

    final bool appExists = await canLaunchUrl(uri);

    if (appExists) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final fallback = Uri.parse('https://$text');
      await launchUrl(fallback, mode: LaunchMode.inAppBrowserView);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Code detected',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// TYPE LABEL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _typeLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// RESULT CONTENT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              result,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// ACTION BUTTONS
          Row(
            children: [
              /// OPEN BUTTON
              if (_isOpenable) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openResult(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _actionLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              /// COPY BUTTON
              Expanded(
                child: GestureDetector(
                  onTap: () => _copy(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy_rounded,
                            size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 6),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
