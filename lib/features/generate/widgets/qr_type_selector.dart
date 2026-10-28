import 'package:flutter/material.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/utils/qr_history_item.dart';

class QRTypeSelector extends StatelessWidget {
  final QRType selected;
  final ValueChanged<QRType> onChanged;

  const QRTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _types = [
    (QRType.url, Icons.language_rounded, 'URL'),
    (QRType.text, Icons.text_fields_rounded, 'Text'),
    (QRType.email, Icons.email_outlined, 'Email'),
    (QRType.phone, Icons.phone_outlined, 'Phone'),
    (QRType.wifi, Icons.wifi_rounded, 'WiFi'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final (type, icon, label) = _types[index];
          final isSelected = selected == type;
          return GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: AppColors.ink,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.ink),
                  const SizedBox(width: 6),
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

