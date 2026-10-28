import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/neo_box.dart';

/// ─── APP CARD ────────────────────────────────────────────
/// A NeoBox-based card. Prefer using NeoBox directly; this is a
/// thin wrapper kept for back-compat with existing screens.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      color: color ?? AppColors.surface,
      radius: borderRadius,
      padding: 0,
      onTap: onTap,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}

/// ─── SECTION LABEL ──────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.ink.withValues(alpha: 0.45),
        letterSpacing: 1.5,
      ),
    );
  }
}

/// ─── APP BADGE ───────────────────────────────────────────
class AppBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;

  const AppBadge({
    super.key,
    required this.text,
    this.color = AppColors.primary,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor ?? AppColors.ink,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// ─── APP BUTTON ──────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isPrimary;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.isPrimary = true,
    this.icon,
    this.width,
    this.height = 52,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.ink,
                ),
              )
            else ...[
              if (icon != null) ...[
                Icon(icon, color: AppColors.ink, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ─── ICON ACTION BUTTON ──────────────────────────────────
class IconActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NeoBox(
        color: color ?? AppColors.primary,
        radius: 14,
        padding: 12,
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: AppColors.ink, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

