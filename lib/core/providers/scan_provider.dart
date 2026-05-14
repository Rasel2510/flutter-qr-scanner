import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Scan State ───────────────────────────────────────────────────────────────

class ScanState {
  final bool isCameraMode;
  final String? scanResult;
  final bool torchOn;
  final bool isScanning;

  const ScanState({
    this.isCameraMode = true,
    this.scanResult,
    this.torchOn = false,
    this.isScanning = true,
  });

  ScanState copyWith({
    bool? isCameraMode,
    String? scanResult,
    bool? torchOn,
    bool? isScanning,
    bool clearResult = false,
  }) {
    return ScanState(
      isCameraMode: isCameraMode ?? this.isCameraMode,
      scanResult: clearResult ? null : (scanResult ?? this.scanResult),
      torchOn: torchOn ?? this.torchOn,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

// ─── Scan Notifier ────────────────────────────────────────────────────────────

class ScanNotifier extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  void onDetected(String value) {
    state = state.copyWith(
      scanResult: value,
      isScanning: false,
    );
  }

  void resetScan() {
    state = state.copyWith(
      clearResult: true,
      isScanning: true,
      torchOn: false,
    );
  }

  void toggleTorch() {
    state = state.copyWith(torchOn: !state.torchOn);
  }

  void switchMode(bool toCamera) {
    if (state.isCameraMode == toCamera) return;
    state = ScanState(isCameraMode: toCamera);
  }

  void setResult(String result) {
    state = state.copyWith(scanResult: result, isScanning: false);
  }
}

final scanProvider =
    NotifierProvider<ScanNotifier, ScanState>(ScanNotifier.new);
