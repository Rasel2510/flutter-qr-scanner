import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A neo-brutalist card: rounded corners, 2 px ink border, hard offset shadow.
class NeoBox extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;
  final double padding;
  final double offset;
  final VoidCallback? onTap;

  const NeoBox({
    super.key,
    required this.child,
    this.color,
    this.radius = 14,
    this.padding = 16,
    this.offset = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink,
            offset: Offset(offset, offset),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: box);
    }
    return box;
  }
}

