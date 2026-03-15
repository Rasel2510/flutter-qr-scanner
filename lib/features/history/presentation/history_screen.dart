import 'package:flutter/material.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/utils/history_manager.dart';
import 'package:qrcraft/core/utils/qr_history_item.dart';
import 'package:qrcraft/features/history/widgets/history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QRHistoryItem> _items = [];
  String _filter = 'all'; // all, generated, scanned
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final items = await HistoryManager.getAll();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  List<QRHistoryItem> get _filtered {
    if (_filter == 'generated') {
      return _items.where((i) => i.mode == QRMode.generated).toList();
    }
    if (_filter == 'scanned') {
      return _items.where((i) => i.mode == QRMode.scanned).toList();
    }
    return _items;
  }

  Future<void> _delete(String id) async {
    await HistoryManager.delete(id);
    _loadHistory();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All History',
            style:
                TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        content: const Text(
            'This will delete all your QR history. This cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear All',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryManager.clearAll();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('History',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                                letterSpacing: -0.5)),
                        SizedBox(height: 4),
                        Text('Your generated & scanned codes',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (_items.isNotEmpty)
                    GestureDetector(
                      onTap: _clearAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: const Text('Clear All',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error)),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// FILTER TABS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _FilterTabs(
                selected: _filter,
                onChanged: (f) => setState(() => _filter = f),
                allCount: _items.length,
                generatedCount:
                    _items.where((i) => i.mode == QRMode.generated).length,
                scannedCount:
                    _items.where((i) => i.mode == QRMode.scanned).length,
              ),
            ),

            const SizedBox(height: 16),

            /// LIST
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.bgCard,
                      onRefresh: _loadHistory,
                      child: _filtered.isEmpty
                          ? CustomScrollView(
                              slivers: [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _EmptyState(filter: _filter),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _filtered[index];
                                return HistoryCard(
                                  item: item,
                                  onDelete: () => _delete(item.id),
                                  onReload: () {
                                    // Navigate back to generate tab handled in main screen
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── FILTER TABS ─────────────────────────────────────────
class _FilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final int allCount, generatedCount, scannedCount;

  const _FilterTabs({
    required this.selected,
    required this.onChanged,
    required this.allCount,
    required this.generatedCount,
    required this.scannedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Tab(
            label: 'All',
            count: allCount,
            isSelected: selected == 'all',
            onTap: () => onChanged('all')),
        const SizedBox(width: 8),
        _Tab(
            label: 'Generated',
            count: generatedCount,
            isSelected: selected == 'generated',
            onTap: () => onChanged('generated')),
        const SizedBox(width: 8),
        _Tab(
            label: 'Scanned',
            count: scannedCount,
            isSelected: selected == 'scanned',
            onTap: () => onChanged('scanned')),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab(
      {required this.label,
      required this.count,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : AppColors.textSecondary)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── EMPTY STATE ─────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            filter == 'all' ? 'No history yet' : 'No $filter QR codes',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            filter == 'all'
                ? 'Generate or scan a QR code\nto see it here'
                : 'Nothing to show for this filter',
            style: const TextStyle(
                fontSize: 14, color: AppColors.textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
