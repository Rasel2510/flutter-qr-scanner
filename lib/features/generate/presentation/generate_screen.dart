import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/providers/generate_provider.dart';
import 'package:qrcraft/core/providers/history_provider.dart';
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
      // Input was empty — show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.warning, size: 18),
            SizedBox(width: 10),
            Text('Please enter some content first',
                style: TextStyle(color: Colors.black)),
          ]),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Save to history via Riverpod
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
    // Watch generate state — entire screen rebuilds on state changes
    final state = ref.watch(generateProvider);
    final notifier = ref.read(generateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
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
                      color: AppColors.text,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              const Text('Generate a code for any content',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary)),

              const SizedBox(height: 28),

              /// TYPE SELECTOR
              QRTypeSelector(
                selected: state.selectedType,
                onChanged: notifier.setType,
              ),

              const SizedBox(height: 20),

              /// INPUT FORM
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text('Generate',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
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
