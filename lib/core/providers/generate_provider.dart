import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import '../utils/qr_history_item.dart';

// ─── Generate State ───────────────────────────────────────────────────────────

class GenerateState {
  final QRType selectedType;
  final String inputValue;
  final String generatedContent;
  final bool hasGenerated;
  final Color fgColor;
  final Color bgColor;
  final double size;
  final String ecLevel;

  const GenerateState({
    this.selectedType = QRType.url,
    this.inputValue = '',
    this.generatedContent = '',
    this.hasGenerated = false,
    this.fgColor = AppColors.primary,
    this.bgColor = Colors.white,
    this.size = 256,
    this.ecLevel = 'M',
  });

  GenerateState copyWith({
    QRType? selectedType,
    String? inputValue,
    String? generatedContent,
    bool? hasGenerated,
    Color? fgColor,
    Color? bgColor,
    double? size,
    String? ecLevel,
  }) {
    return GenerateState(
      selectedType: selectedType ?? this.selectedType,
      inputValue: inputValue ?? this.inputValue,
      generatedContent: generatedContent ?? this.generatedContent,
      hasGenerated: hasGenerated ?? this.hasGenerated,
      fgColor: fgColor ?? this.fgColor,
      bgColor: bgColor ?? this.bgColor,
      size: size ?? this.size,
      ecLevel: ecLevel ?? this.ecLevel,
    );
  }
}

// ─── Generate Notifier ────────────────────────────────────────────────────────

class GenerateNotifier extends Notifier<GenerateState> {
  @override
  GenerateState build() => const GenerateState();

  void setType(QRType type) {
    state = state.copyWith(
      selectedType: type,
      inputValue: '',
      hasGenerated: false,
      generatedContent: '',
    );
  }

  void setInput(String value) {
    state = state.copyWith(inputValue: value);
  }

  void setFgColor(Color color) => state = state.copyWith(fgColor: color);
  void setBgColor(Color color) => state = state.copyWith(bgColor: color);
  void setSize(double size) => state = state.copyWith(size: size);
  void setEcLevel(String level) => state = state.copyWith(ecLevel: level);

  /// Returns the QR content string if valid, null otherwise (caller shows snackbar).
  String? generate() {
    if (state.inputValue.trim().isEmpty) return null;
    state = state.copyWith(
      generatedContent: state.inputValue,
      hasGenerated: true,
    );
    return state.inputValue;
  }
}

final generateProvider =
    NotifierProvider<GenerateNotifier, GenerateState>(GenerateNotifier.new);
