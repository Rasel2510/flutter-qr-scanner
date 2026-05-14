import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/history_manager.dart';
import '../utils/qr_history_item.dart';

// ─── History State ────────────────────────────────────────────────────────────

class HistoryState {
  final List<QRHistoryItem> items;
  final bool isLoading;
  final String filter; // 'all' | 'generated' | 'scanned'

  const HistoryState({
    this.items = const [],
    this.isLoading = true,
    this.filter = 'all',
  });

  List<QRHistoryItem> get filtered {
    if (filter == 'generated') {
      return items.where((i) => i.mode == QRMode.generated).toList();
    }
    if (filter == 'scanned') {
      return items.where((i) => i.mode == QRMode.scanned).toList();
    }
    return items;
  }

  int get generatedCount =>
      items.where((i) => i.mode == QRMode.generated).length;
  int get scannedCount => items.where((i) => i.mode == QRMode.scanned).length;

  HistoryState copyWith({
    List<QRHistoryItem>? items,
    bool? isLoading,
    String? filter,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
    );
  }
}

// ─── History Notifier ─────────────────────────────────────────────────────────

class HistoryNotifier extends AsyncNotifier<HistoryState> {
  @override
  Future<HistoryState> build() async {
    final items = await HistoryManager.getAll();
    return HistoryState(items: items, isLoading: false);
  }

  Future<void> load() async {
    state = AsyncData(state.valueOrNull?.copyWith(isLoading: true) ??
        const HistoryState());
    final items = await HistoryManager.getAll();
    state = AsyncData(
        (state.valueOrNull ?? const HistoryState())
            .copyWith(items: items, isLoading: false));
  }

  Future<void> addGenerated({
    required QRType type,
    required String content,
    String? fgColor,
    String? bgColor,
  }) async {
    await HistoryManager.add(
      mode: QRMode.generated,
      type: type,
      label: QRHistoryItem.typeLabel(type),
      content: content,
      fgColor: fgColor,
      bgColor: bgColor,
    );
    await load();
  }

  Future<void> addScanned(String content) async {
    final type = QRHistoryItem.detectType(content);
    await HistoryManager.add(
      mode: QRMode.scanned,
      type: type,
      label: QRHistoryItem.typeLabel(type),
      content: content,
    );
    await load();
  }

  Future<void> delete(String id) async {
    await HistoryManager.delete(id);
    await load();
  }

  Future<void> clearAll() async {
    await HistoryManager.clearAll();
    await load();
  }

  void setFilter(String filter) {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(filter: filter));
    }
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);
