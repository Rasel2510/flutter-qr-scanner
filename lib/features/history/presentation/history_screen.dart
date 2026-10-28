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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        title: const Text('Clear All History',
            style: TextStyle(
                color: AppColors.ink, fontWeight: FontWeight.w700)),
        content: Text(
            'This will delete all your QR history. This cannot be undone.',
            style: TextStyle(color: AppColors.ink.withValues(alpha: 0.7))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.ink.withValues(alpha: 0.55)))),
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
    final asyncHistory = ref.watch(historyProvider);

    return asyncHistory.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $e')),
      ),
      data: (historyState) {
        final items = historyState.items;
        final filtered = historyState.filtered;

        return Scaffold(
          backgroundColor: AppColors.background,
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
                                    color: AppColors.ink)),
                            SizedBox(height: 4),
                            Text('Your generated & scanned codes',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.ink)),
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
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.ink, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.ink,
                                  offset: Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Text('Clear All',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.surface)),
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
                          color: AppColors.ink,
                          backgroundColor: AppColors.primary,
                          onRefresh: () =>
                              ref.read(historyProvider.notifier).load(),
                          child: filtered.isEmpty
                              ? CustomScrollView(
                                  slivers: [
                                    SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: _EmptyState(
                                          filter: historyState.filter),
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
          // Flat shape illustration — dots, triangle, circle in coral/sky/green
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(painter: _EmptyIllustrationPainter()),
          ),
          const SizedBox(height: 20),
          Text(
            filter == 'all' ? 'No history yet' : 'No $filter QR codes',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          Text(
            filter == 'all'
                ? 'Generate or scan a QR code\nto see it here'
                : 'Nothing to show for this filter',
            style: TextStyle(
                fontSize: 14,
                color: AppColors.ink.withValues(alpha: 0.55),
                height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Flat shape illustration using AppColors palette
class _EmptyIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final ink = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Large circle (sky blue)
    canvas.drawCircle(
        Offset(cx, cy),
        38,
        Paint()
          ..color = AppColors.info
          ..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), 38, ink);

    // Triangle (coral)
    final tri = Path()
      ..moveTo(cx - 18, cy + 14)
      ..lineTo(cx + 18, cy + 14)
      ..lineTo(cx, cy - 18)
      ..close();
    canvas.drawPath(tri,
        Paint()
          ..color = AppColors.secondary
          ..style = PaintingStyle.fill);
    canvas.drawPath(tri, ink);

    // Dot top-right (green)
    canvas.drawCircle(
        Offset(cx + 30, cy - 28),
        10,
        Paint()
          ..color = AppColors.success
          ..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx + 30, cy - 28), 10, ink);

    // Dot bottom-left (yellow)
    canvas.drawCircle(
        Offset(cx - 32, cy + 22),
        8,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx - 32, cy + 22), 8, ink);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

