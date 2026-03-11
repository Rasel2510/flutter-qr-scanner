import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class QRCustomizeOptions extends StatefulWidget {
  final Color fgColor;
  final Color bgColor;
  final double size;
  final String ecLevel;
  final ValueChanged<Color> onFgChanged;
  final ValueChanged<Color> onBgChanged;
  final ValueChanged<double> onSizeChanged;
  final ValueChanged<String> onEcChanged;

  const QRCustomizeOptions({
    super.key,
    required this.fgColor,
    required this.bgColor,
    required this.size,
    required this.ecLevel,
    required this.onFgChanged,
    required this.onBgChanged,
    required this.onSizeChanged,
    required this.onEcChanged,
  });

  @override
  State<QRCustomizeOptions> createState() => _QRCustomizeOptionsState();
}

class _QRCustomizeOptionsState extends State<QRCustomizeOptions> {
  bool _expanded = false;

  static const _sizes = [
    (200.0, 'Small'),
    (256.0, 'Medium'),
    (350.0, 'Large'),
    (480.0, 'XL'),
  ];

  static const _ecLevels = [
    ('L', 'Low 7%'),
    ('M', 'Med 15%'),
    ('Q', 'High 25%'),
    ('H', 'Max 30%'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          /// HEADER
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  const Text('Customize',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text)),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted, size: 20),
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),

                  /// COLORS
                  Row(
                    children: [
                      Expanded(
                          child: _colorPicker('Foreground', widget.fgColor,
                              widget.onFgChanged)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _colorPicker('Background', widget.bgColor,
                              widget.onBgChanged)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// SIZE
                  const Text('Size',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    children: _sizes.map((s) {
                      final (size, label) = s;
                      final isSelected = widget.size == size;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onSizeChanged(size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  /// ERROR CORRECTION
                  const Text('Error Correction',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    children: _ecLevels.map((e) {
                      final (level, label) = e;
                      final isSelected = widget.ecLevel == level;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onEcChanged(level),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _colorPicker(
      String label, Color current, ValueChanged<Color> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showColorPicker(context, current, onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: current,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '#${current.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(
      BuildContext context, Color current, ValueChanged<Color> onChanged) {
    final colors = [
      Colors.black,
      Colors.white,
      AppColors.primary,
      AppColors.accent,
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFFF87171),
      const Color(0xFF06B6D4),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      Colors.brown,
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.pink,
      Colors.grey,
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pick Color',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors
                  .map((c) => GestureDetector(
                        onTap: () {
                          onChanged(c);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: c == current
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: c == current ? 2.5 : 1),
                          ),
                          child: c == current
                              ? Icon(Icons.check,
                                  color: c == Colors.white
                                      ? AppColors.text
                                      : Colors.white,
                                  size: 16)
                              : null,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
