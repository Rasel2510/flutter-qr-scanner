import 'package:flutter/material.dart';
import 'package:qrcraft/core/theme/app_theme.dart';

class FilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final int allCount;
  final int generatedCount;
  final int scannedCount;

  const FilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.allCount,
    required this.generatedCount,
    required this.scannedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Tab(
            label: 'All',
            count: allCount,
            isSelected: selected == 'all',
            onTap: () => onChanged('all')),
        const SizedBox(width: 8),
        _Tab(
            label: 'Generated',
            count: generatedCount,
            isSelected: selected == 'generated',
            onTap: () => onChanged('generated')),
        const SizedBox(width: 8),
        _Tab(
            label: 'Scanned',
            count: scannedCount,
            isSelected: selected == 'scanned',
            onTap: () => onChanged('scanned')),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected ? Colors.white : AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}