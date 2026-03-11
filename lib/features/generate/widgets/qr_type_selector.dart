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
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (type, icon, label) = _types[index];
          final isSelected = selected == type;
          return GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      size: 15,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
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
