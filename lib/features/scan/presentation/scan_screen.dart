import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/utils/history_manager.dart';
import 'package:qrcraft/core/utils/qr_history_item.dart';
import 'package:qrcraft/features/scan/widgets/scan_result_widget.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  late MobileScannerController _controller;
  bool _scanMode = true; // true = camera, false = upload
  String? _scanResult;
  bool _torchOn = false;
  bool _isScanning = true;

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
    switch (state) {
      case AppLifecycleState.resumed:
        if (_isScanning && _scanMode) _controller.start();
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
    if (!_isScanning) return;
    if (capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    // Stop camera immediately so it doesn't keep firing
    _controller.stop();

    setState(() {
      _scanResult = value;
      _isScanning = false;
    });
    _saveToHistory(value);
  }

  void _saveToHistory(String content) {
    final type = QRHistoryItem.detectType(content);
    HistoryManager.add(
      mode: QRMode.scanned,
      type: type,
      label: QRHistoryItem.typeLabel(type),
      content: content,
    );
  }

  /// Dismiss result → restart camera for next scan
  void _resetScan() {
    setState(() {
      _scanResult = null;
      _isScanning = true;
      _torchOn = false;
    });
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
        setState(() {
          _scanResult = value;
          _isScanning = false;
        });
        _saveToHistory(value);
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
    if (_scanMode == toCamera) return;
    setState(() {
      _scanMode = toCamera;
      _scanResult = null;
      _isScanning = true;
      _torchOn = false;
    });
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
              _ModeToggle(isCameraMode: _scanMode, onToggle: _switchMode),
              const SizedBox(height: 20),
              if (_scanMode)
                _CameraSection(
                  controller: _controller,
                  torchOn: _torchOn,
                  onDetect: _onDetect,
                  onToggleTorch: () {
                    setState(() => _torchOn = !_torchOn);
                    _controller.toggleTorch();
                  },
                  onPickGallery: _pickFromGallery,
                )
              else
                _UploadSection(onPick: _pickFromGallery),
              const SizedBox(height: 20),
              if (_scanResult != null)
                ScanResultWidget(result: _scanResult!, onDismiss: _resetScan),
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

// ─── CAMERA SECTION ──────────────────────────────────────
class _CameraSection extends StatelessWidget {
  final MobileScannerController controller;
  final bool torchOn;
  final void Function(BarcodeCapture) onDetect;
  final VoidCallback onToggleTorch;
  final VoidCallback onPickGallery;
  const _CameraSection(
      {required this.controller,
      required this.torchOn,
      required this.onDetect,
      required this.onToggleTorch,
      required this.onPickGallery});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 320,
          child: Stack(fit: StackFit.expand, children: [
            MobileScanner(controller: controller, onDetect: onDetect),
            const _ScanOverlay(),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onToggleTorch,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: torchOn ? AppColors.warning : Colors.black38,
                      shape: BoxShape.circle),
                  child: Icon(
                      torchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: Colors.white,
                      size: 20),
                ),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: onPickGallery,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child:
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.photo_library_outlined, color: AppColors.text, size: 18),
            SizedBox(width: 8),
            Text('Pick from Gallery',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text)),
          ]),
        ),
      ),
    ]);
  }
}

// ─── SCAN OVERLAY ────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ScanFramePainter());
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const frameSize = 200.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - frameSize / 2;
    final top = cy - frameSize / 2;
    final right = cx + frameSize / 2;
    final bottom = cy + frameSize / 2;

    // Dim overlay outside frame
    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.38);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), dimPaint);
    canvas.drawRect(
        Rect.fromLTRB(0, bottom, size.width, size.height), dimPaint);
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), dimPaint);
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), dimPaint);

    // Corner brackets
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cl = 28.0; // corner length
    const r = 6.0; // corner radius

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(left, top + cl)
          ..lineTo(left, top + r)
          ..arcToPoint(Offset(left + r, top), radius: const Radius.circular(r))
          ..lineTo(left + cl, top),
        paint);
    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(right - cl, top)
          ..lineTo(right - r, top)
          ..arcToPoint(Offset(right, top + r), radius: const Radius.circular(r))
          ..lineTo(right, top + cl),
        paint);
    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(left, bottom - cl)
          ..lineTo(left, bottom - r)
          ..arcToPoint(Offset(left + r, bottom),
              radius: const Radius.circular(r))
          ..lineTo(left + cl, bottom),
        paint);
    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(right, bottom - cl)
          ..lineTo(right, bottom - r)
          ..arcToPoint(Offset(right - r, bottom),
              radius: const Radius.circular(r), clockwise: false)
          ..lineTo(right - cl, bottom),
        paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── UPLOAD SECTION ──────────────────────────────────────
class _UploadSection extends StatelessWidget {
  final VoidCallback onPick;
  const _UploadSection({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
        child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_rounded,
                  color: AppColors.textMuted, size: 36),
              SizedBox(height: 14),
              Text('Tap to browse',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text)),
              SizedBox(height: 4),
              Text('PNG · JPG · WEBP',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ]),
      ),
    );
  }
}
