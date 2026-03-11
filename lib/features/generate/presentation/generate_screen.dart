import 'package:flutter/material.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/utils/history_manager.dart';
import 'package:qrcraft/core/utils/qr_history_item.dart';
import 'package:qrcraft/features/generate/widgets/qr_customize_options.dart';
import 'package:qrcraft/features/generate/widgets/qr_input_form.dart';
import 'package:qrcraft/features/generate/widgets/qr_preview_widget.dart';
import 'package:qrcraft/features/generate/widgets/qr_type_selector.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  QRType _selectedType = QRType.url;
  String _inputValue = '';
  String _generatedContent = '';
  bool _hasGenerated = false;

  Color _fgColor = AppColors.primary;
  Color _bgColor = Colors.white;
  double _size = 256;
  String _ecLevel = 'M';

  void _onGenerate() {
    if (_inputValue.trim().isEmpty) {
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
    setState(() {
      _generatedContent = _inputValue;
      _hasGenerated = true;
    });

    // Save to history
    HistoryManager.add(
      mode: QRMode.generated,
      type: _selectedType,
      label: QRHistoryItem.typeLabel(_selectedType),
      content: _inputValue,
      fgColor:
          '#${_fgColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      bgColor:
          '#${_bgColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    );
  }

  @override
  Widget build(BuildContext context) {
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
                selected: _selectedType,
                onChanged: (type) => setState(() {
                  _selectedType = type;
                  _inputValue = '';
                  _hasGenerated = false;
                }),
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
                  type: _selectedType,
                  onChanged: (val) => setState(() => _inputValue = val),
                ),
              ),

              const SizedBox(height: 14),

              /// CUSTOMIZE
              QRCustomizeOptions(
                fgColor: _fgColor,
                bgColor: _bgColor,
                size: _size,
                ecLevel: _ecLevel,
                onFgChanged: (c) => setState(() => _fgColor = c),
                onBgChanged: (c) => setState(() => _bgColor = c),
                onSizeChanged: (s) => setState(() => _size = s),
                onEcChanged: (e) => setState(() => _ecLevel = e),
              ),

              const SizedBox(height: 20),

              /// GENERATE BUTTON
              GestureDetector(
                onTap: _onGenerate,
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
              if (_hasGenerated && _generatedContent.isNotEmpty)
                QRPreviewWidget(
                  content: _generatedContent,
                  fgColor: _fgColor,
                  bgColor: _bgColor,
                  size: _size,
                  ecLevel: _ecLevel,
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
