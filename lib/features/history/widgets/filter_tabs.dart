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
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
