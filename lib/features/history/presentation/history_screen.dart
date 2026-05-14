import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrcraft/core/theme/app_theme.dart';
import 'package:qrcraft/core/providers/history_provider.dart';
import 'package:qrcraft/features/history/widgets/filter_tabs.dart';
import 'package:qrcraft/features/history/widgets/history_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
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
      ref.read(historyProvider.notifier).clearAll();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch history — rebuilds when items change or filter changes
    final asyncHistory = ref.watch(historyProvider);

    return asyncHistory.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: Text('Error: $e')),
      ),
      data: (historyState) {
        final items = historyState.items;
        final filtered = historyState.filtered;

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
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (items.isNotEmpty)
                        GestureDetector(
                          onTap: () => _clearAll(context, ref),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.3)),
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
                  child: FilterTabs(
                    selected: historyState.filter,
                    onChanged: (f) =>
                        ref.read(historyProvider.notifier).setFilter(f),
                    allCount: items.length,
                    generatedCount: historyState.generatedCount,
                    scannedCount: historyState.scannedCount,
                  ),
                ),

                const SizedBox(height: 16),

                /// LIST
                Expanded(
                  child: historyState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.bgCard,
                          onRefresh: () =>
                              ref.read(historyProvider.notifier).load(),
                          child: filtered.isEmpty
                              ? CustomScrollView(
                                  slivers: [
                                    SliverFillRemaining(
                                      hasScrollBody: false,
                                      child:
                                          _EmptyState(filter: historyState.filter),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                      24, 0, 24, 24),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = filtered[index];
                                    return HistoryCard(
                                      item: item,
                                      onDelete: () => ref
                                          .read(historyProvider.notifier)
                                          .delete(item.id),
                                      onReload: () {},
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
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
