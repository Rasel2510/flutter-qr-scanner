import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/providers/generate_provider.dart';
import 'package:qrcraft/core/providers/history_provider.dart';
import 'package:qrcraft/core/widgets/neo_box.dart';
import 'package:qrcraft/features/generate/widgets/qr_customize_options.dart';
import 'package:qrcraft/features/generate/widgets/qr_input_form.dart';
import 'package:qrcraft/features/generate/widgets/qr_preview_widget.dart';
import 'package:qrcraft/features/generate/widgets/qr_type_selector.dart';

class GenerateScreen extends ConsumerWidget {
  const GenerateScreen({super.key});

  void _onGenerate(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(generateProvider.notifier);
    final state = ref.read(generateProvider);

    final content = notifier.generate();

    if (content == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.backdrop, size: 18),
            SizedBox(width: 10),
            Text('Please enter some content first'),
          ]),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    ref.read(historyProvider.notifier).addGenerated(
          type: state.selectedType,
          content: content,
          fgColor:
              '#${state.fgColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
          bgColor:
              '#${state.bgColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(generateProvider);
    final notifier = ref.read(generateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              /// HEADER
              const Text('Create QR',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
              const SizedBox(height: 4),
              Text('Generate a code for any content',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.ink.withValues(alpha: 0.55))),

              const SizedBox(height: 28),

              /// TYPE SELECTOR
              QRTypeSelector(
                selected: state.selectedType,
                onChanged: notifier.setType,
              ),

              const SizedBox(height: 20),

              /// INPUT FORM in NeoBox
              NeoBox(
                color: AppColors.surface,
                radius: 14,
                padding: 18,
                child: QRInputForm(
                  type: state.selectedType,
                  onChanged: notifier.setInput,
                ),
              ),

              const SizedBox(height: 14),

              /// CUSTOMIZE
              QRCustomizeOptions(
                fgColor: state.fgColor,
                bgColor: state.bgColor,
                size: state.size,
                ecLevel: state.ecLevel,
                onFgChanged: notifier.setFgColor,
                onBgChanged: notifier.setBgColor,
                onSizeChanged: notifier.setSize,
                onEcChanged: notifier.setEcLevel,
              ),

              const SizedBox(height: 20),

              /// GENERATE BUTTON
              GestureDetector(
                onTap: () => _onGenerate(context, ref),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded,
                          color: AppColors.ink, size: 20),
                      SizedBox(width: 10),
                      Text('GENERATE',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.ink)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// QR PREVIEW
              if (state.hasGenerated && state.generatedContent.isNotEmpty)
                QRPreviewWidget(
                  content: state.generatedContent,
                  fgColor: state.fgColor,
                  bgColor: state.bgColor,
                  size: state.size,
                  ecLevel: state.ecLevel,
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

