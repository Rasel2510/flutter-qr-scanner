import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/qr_history_item.dart';

class QRInputForm extends StatefulWidget {
  final QRType type;
  final ValueChanged<String> onChanged;

  const QRInputForm({
    super.key,
    required this.type,
    required this.onChanged,
  });

  @override
  State<QRInputForm> createState() => _QRInputFormState();
}

class _QRInputFormState extends State<QRInputForm> {
  final _urlCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _emailSubCtrl = TextEditingController();
  final _emailBodyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _wifiSsidCtrl = TextEditingController();
  final _wifiPassCtrl = TextEditingController();
  String _wifiSecurity = 'WPA';
  bool _obscurePass = true;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _textCtrl.dispose();
    _emailCtrl.dispose();
    _emailSubCtrl.dispose();
    _emailBodyCtrl.dispose();
    _phoneCtrl.dispose();
    _wifiSsidCtrl.dispose();
    _wifiPassCtrl.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged(_buildValue());

  String _buildValue() {
    switch (widget.type) {
      case QRType.url:
        return _urlCtrl.text;
      case QRType.text:
        return _textCtrl.text;
      case QRType.email:
        final email = _emailCtrl.text;
        if (email.isEmpty) return '';
        String mailto = 'mailto:$email';
        final params = <String>[];
        if (_emailSubCtrl.text.isNotEmpty) {
          params.add('subject=${Uri.encodeComponent(_emailSubCtrl.text)}');
        }
        if (_emailBodyCtrl.text.isNotEmpty) {
          params.add('body=${Uri.encodeComponent(_emailBodyCtrl.text)}');
        }
        if (params.isNotEmpty) mailto += '?${params.join('&')}';
        return mailto;
      case QRType.phone:
        return _phoneCtrl.text.isEmpty ? '' : 'tel:${_phoneCtrl.text}';
      case QRType.wifi:
        final ssid = _wifiSsidCtrl.text;
        if (ssid.isEmpty) return '';
        return 'WIFI:T:$_wifiSecurity;S:$ssid;P:${_wifiPassCtrl.text};;';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(
        key: ValueKey(widget.type),
        child: _buildFields(),
      ),
    );
  }

  Widget _buildFields() {
    switch (widget.type) {
      case QRType.url:
        return _field(
          label: 'Website URL',
          controller: _urlCtrl,
          hint: 'https://example.com',
          icon: Icons.language_rounded,
          keyboardType: TextInputType.url,
        );
      case QRType.text:
        return _textArea(
          label: 'Text Content',
          controller: _textCtrl,
          hint: 'Enter any text...',
        );
      case QRType.email:
        return Column(
          children: [
            _field(
                label: 'Email Address',
                controller: _emailCtrl,
                hint: 'hello@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _field(
                label: 'Subject (optional)',
                controller: _emailSubCtrl,
                hint: 'Subject line',
                icon: Icons.subject_rounded),
            const SizedBox(height: 14),
            _textArea(
                label: 'Body (optional)',
                controller: _emailBodyCtrl,
                hint: 'Email body...'),
          ],
        );
      case QRType.phone:
        return _field(
          label: 'Phone Number',
          controller: _phoneCtrl,
          hint: '+1 234 567 8900',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        );
      case QRType.wifi:
        return Column(
          children: [
            _field(
                label: 'Network Name (SSID)',
                controller: _wifiSsidCtrl,
                hint: 'MyNetwork',
                icon: Icons.wifi_rounded),
            const SizedBox(height: 14),
            _passwordField(),
            const SizedBox(height: 14),
            _securityDropdown(),
          ],
        );
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          onChanged: (_) => _notify(),
          decoration: _inputDecoration(
              hint: hint,
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18)),
        ),
      ],
    );
  }

  Widget _textArea(
      {required String label,
      required TextEditingController controller,
      required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          onChanged: (_) => _notify(),
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Password'),
        const SizedBox(height: 8),
        TextField(
          controller: _wifiPassCtrl,
          obscureText: _obscurePass,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          onChanged: (_) => _notify(),
          decoration: _inputDecoration(
            hint: 'WiFi password',
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.textMuted, size: 18),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePass = !_obscurePass),
              child: Icon(
                  _obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _securityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Security Type'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _wifiSecurity,
          dropdownColor: AppColors.bgCard,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: _inputDecoration(hint: ''),
          items: ['WPA', 'WEP', 'None']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() => _wifiSecurity = v!);
            _notify();
          },
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.8),
      );

  InputDecoration _inputDecoration(
      {required String hint, Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(right: 12), child: suffixIcon)
          : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
