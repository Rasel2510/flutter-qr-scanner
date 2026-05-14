import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/providers/scan_provider.dart';
import 'package:qrcraft/core/providers/history_provider.dart';
import 'package:qrcraft/features/scan/widgets/camara_section.dart';
import 'package:qrcraft/features/scan/widgets/scan_result_widget.dart';
import 'package:qrcraft/features/scan/widgets/upload_section.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  late MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  void _initController() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final scanState = ref.read(scanProvider);
    switch (state) {
      case AppLifecycleState.resumed:
        if (scanState.isScanning && scanState.isCameraMode) {
          _controller.start();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _controller.stop();
        break;
      default:
        break;
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final isScanning = ref.read(scanProvider).isScanning;
    if (!isScanning) return;
    if (capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _controller.stop();

    // Update scan state via provider
    ref.read(scanProvider.notifier).onDetected(value);

    // Save to history via provider
    ref.read(historyProvider.notifier).addScanned(value);
  }

  void _resetScan() {
    ref.read(scanProvider.notifier).resetScan();
    _controller.start();
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final result = await _controller.analyzeImage(image.path);
    if (result != null && result.barcodes.isNotEmpty) {
      final value = result.barcodes.first.rawValue;
      if (value != null && value.isNotEmpty) {
        ref.read(scanProvider.notifier).setResult(value);
        ref.read(historyProvider.notifier).addScanned(value);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 18),
              SizedBox(width: 10),
              Text('No QR code found in image',
                  style: TextStyle(color: Colors.black)),
            ]),
            backgroundColor: AppColors.bgCard,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _switchMode(bool toCamera) {
    ref.read(scanProvider.notifier).switchMode(toCamera);
    if (toCamera) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _controller.start();
      });
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch scan state — rebuilds automatically on changes
    final scanState = ref.watch(scanProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text('Scan QR',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              const Text('Use camera or pick from gallery',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              _ModeToggle(
                  isCameraMode: scanState.isCameraMode,
                  onToggle: _switchMode),
              const SizedBox(height: 20),
              if (scanState.isCameraMode)
                CameraSection(
                  controller: _controller,
                  torchOn: scanState.torchOn,
                  onDetect: _onDetect,
                  onToggleTorch: () {
                    ref.read(scanProvider.notifier).toggleTorch();
                    _controller.toggleTorch();
                  },
                  onPickGallery: _pickFromGallery,
                )
              else
                UploadSection(onPick: _pickFromGallery),
              const SizedBox(height: 20),
              if (scanState.scanResult != null)
                ScanResultWidget(
                    result: scanState.scanResult!, onDismiss: _resetScan),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── MODE TOGGLE ─────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final bool isCameraMode;
  final ValueChanged<bool> onToggle;
  const _ModeToggle({required this.isCameraMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(children: [
        _TabBtn(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            isActive: isCameraMode,
            onTap: () => onToggle(true)),
        _TabBtn(
            icon: Icons.photo_library_rounded,
            label: 'Upload',
            isActive: !isCameraMode,
            onTap: () => onToggle(false)),
      ]),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabBtn(
      {required this.icon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? AppColors.bgCard : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 16,
                color: isActive ? AppColors.text : AppColors.textMuted),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? AppColors.text : AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }
}
