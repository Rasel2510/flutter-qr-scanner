import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/qr_history_item.dart';
import '../../../core/widgets/neo_box.dart';

class ScanResultWidget extends StatefulWidget {
  final String result;
  final VoidCallback onDismiss;

  const ScanResultWidget({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  @override
  State<ScanResultWidget> createState() => _ScanResultWidgetState();
}

class _ScanResultWidgetState extends State<ScanResultWidget> {
  bool _isConnecting = false;
  String? _connectStatus; // null | 'success' | 'error'

  QRType get _type => QRHistoryItem.detectType(widget.result);
  String get _typeLabel => QRHistoryItem.typeLabel(_type);

  bool get _isOpenable =>
      _type == QRType.url || _type == QRType.email || _type == QRType.phone;

  bool get _isWifi => _type == QRType.wifi;

  Map<String, String> get _wifiCreds =>
      QRHistoryItem.parseWifiCredentials(widget.result);

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
    Clipboard.setData(ClipboardData(text: widget.result));
    _showSnackbar(context, Icons.copy_rounded, 'Copied to clipboard');
  }

  /// OPEN RESULT
  Future<void> _openResult(BuildContext context) async {
    final text = widget.result.trim();
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
        final email =
            text.toLowerCase().startsWith('mailto:') ? text.substring(7) : text;
        uri = Uri(scheme: 'mailto', path: email.trim());
        break;

      case QRType.phone:
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

  /// CONNECT TO WIFI
  Future<void> _connectWifi(BuildContext context) async {
    final creds = _wifiCreds;
    final ssid = creds['ssid'] ?? '';
    final password = creds['password'] ?? '';
    final authType = creds['type'] ?? 'WPA';

    if (ssid.isEmpty) {
      _showSnackbar(
          context, Icons.error_outline_rounded, 'Could not read SSID from QR code');
      return;
    }

    setState(() {
      _isConnecting = true;
      _connectStatus = null;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      if (password.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: password));
      }

      NetworkSecurity security;
      switch (authType.toUpperCase()) {
        case 'WPA':
        case 'WPA2':
          security = NetworkSecurity.WPA;
          break;
        case 'WEP':
          security = NetworkSecurity.WEP;
          break;
        case 'NOPASS':
        case '':
          security = NetworkSecurity.NONE;
          break;
        default:
          security = NetworkSecurity.WPA;
      }

      final connected = await WiFiForIoTPlugin.connect(
        ssid,
        password: password.isEmpty ? null : password,
        security: security,
        joinOnce: false,
        withInternet: true,
      );

      if (!mounted) return;

      if (connected) {
        setState(() => _connectStatus = 'success');
        messenger.showSnackBar(_buildSnackBar(
            Icons.wifi_rounded, 'Connected to "$ssid"'));
      } else {
        setState(() => _connectStatus = 'error');
        messenger.showSnackBar(_buildSnackBar(
            Icons.wifi_off_rounded,
            'Could not connect — password copied, try manually'));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _connectStatus = 'error');
      messenger.showSnackBar(_buildSnackBar(
          Icons.wifi_off_rounded,
          'Error: ${e.toString().split('\n').first}'));
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  SnackBar _buildSnackBar(IconData icon, String message) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void _showSnackbar(BuildContext context, IconData icon, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(icon, message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      color: AppColors.surface,
      radius: 14,
      padding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER STRIP ─────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                  bottom: BorderSide(color: AppColors.ink, width: 2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.ink,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'CODE DETECTED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.ink, width: 2),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.ink,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TYPE BADGE ────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  child: Text(
                    _typeLabel.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.ink,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── WiFi CARD ─────────────────────────
                if (_isWifi) ...[
                  _WifiInfoCard(
                    creds: _wifiCreds,
                    connectStatus: _connectStatus,
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  // ── RESULT CONTENT ─────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.ink, width: 2),
                    ),
                    child: Text(
                      widget.result,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── ACTION BUTTONS ────────────────────
                Row(
                  children: [
                    if (_isWifi) ...[
                      Expanded(
                        child: _NeoActionButton(
                          onTap: _isConnecting
                              ? null
                              : () => _connectWifi(context),
                          isPrimary: true,
                          icon: _isConnecting
                              ? null
                              : (_connectStatus == 'success'
                                  ? Icons.wifi_rounded
                                  : Icons.wifi_find_rounded),
                          label: _isConnecting
                              ? 'Connecting...'
                              : (_connectStatus == 'success'
                                  ? 'Connected!'
                                  : 'Connect to WiFi'),
                          isLoading: _isConnecting,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],

                    if (_isOpenable) ...[
                      Expanded(
                        child: _NeoActionButton(
                          onTap: () => _openResult(context),
                          isPrimary: true,
                          icon: Icons.open_in_new_rounded,
                          label: _actionLabel,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],

                    Expanded(
                      child: _NeoActionButton(
                        onTap: () => _copy(context),
                        isPrimary: false,
                        icon: Icons.copy_rounded,
                        label: 'Copy',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── WIFI INFO CARD ──────────────────────────────────────────────
class _WifiInfoCard extends StatelessWidget {
  final Map<String, String> creds;
  final String? connectStatus;

  const _WifiInfoCard({required this.creds, this.connectStatus});

  @override
  Widget build(BuildContext context) {
    final ssid = creds['ssid'] ?? '';
    final password = creds['password'] ?? '';
    final type = creds['type'] ?? 'WPA';
    final isOpen = type.toUpperCase() == 'NOPASS' || password.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                connectStatus == 'success'
                    ? Icons.wifi_rounded
                    : Icons.wifi_find_rounded,
                color: AppColors.ink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ssid.isEmpty ? '(No SSID)' : ssid,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _WifiRow(label: 'Security', value: type.isEmpty ? 'Open' : type),
          if (!isOpen)
            _WifiRow(
              label: 'Password',
              value: password,
              isPassword: true,
            ),
        ],
      ),
    );
  }
}

class _WifiRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isPassword;

  const _WifiRow({
    required this.label,
    required this.value,
    this.isPassword = false,
  });

  @override
  State<_WifiRow> createState() => _WifiRowState();
}

class _WifiRowState extends State<_WifiRow> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            '${widget.label}: ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.ink.withValues(alpha: 0.55),
            ),
          ),
          Expanded(
            child: Text(
              widget.isPassword && !_showPassword
                  ? '•' * widget.value.length.clamp(4, 12)
                  : widget.value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.isPassword)
            GestureDetector(
              onTap: () => setState(() => _showPassword = !_showPassword),
              child: Icon(
                _showPassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 16,
                color: AppColors.ink,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── NEO ACTION BUTTON ───────────────────────────────────
class _NeoActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isPrimary;
  final IconData? icon;
  final String label;
  final bool isLoading;

  const _NeoActionButton({
    required this.onTap,
    required this.isPrimary,
    required this.label,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 8),
            ] else if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.ink),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

