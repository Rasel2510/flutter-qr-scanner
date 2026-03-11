import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// ─── APP CARD ───────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.borderRadius = 16,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.bgCard,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? AppColors.border,
          ),
        ),
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
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor ?? color,
          fontFamily: 'monospace',
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF9B8DFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isPrimary ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: isPrimary ? null : Border.all(color: AppColors.border),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white,
                ),
              )
            else ...[
              if (icon != null) ...[
                Icon(icon, color: isPrimary ? Colors.white : AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? Colors.white : AppColors.textSecondary,
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (color ?? AppColors.primary).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color ?? AppColors.primary, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
