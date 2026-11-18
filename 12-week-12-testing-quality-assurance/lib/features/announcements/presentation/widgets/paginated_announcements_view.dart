import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/announcement_providers.dart';
import 'announcement_item_card.dart';

/// Komponen list dengan lazy loading, infinite scroll, dan optimasi memori (Step 4 & 5 Codelab Minggu 11).
class PaginatedAnnouncementsView extends ConsumerStatefulWidget {
  const PaginatedAnnouncementsView({super.key});

  @override
  ConsumerState<PaginatedAnnouncementsView> createState() =>
      _PaginatedAnnouncementsViewState();
}

class _PaginatedAnnouncementsViewState
    extends ConsumerState<PaginatedAnnouncementsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Menghindari memory leak dengan membersihkan controller (Step 6 Codelab)
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // Pemicu saat pengguna mendekati 200px dari dasar daftar
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedAnnouncementsProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginatedState = ref.watch(paginatedAnnouncementsProvider);
    final theme = Theme.of(context);

    if (paginatedState.items.isEmpty && paginatedState.isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (paginatedState.errorMessage != null && paginatedState.items.isEmpty) {
      return Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Gagal memuat: ${paginatedState.errorMessage}',
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Indikator status cache & performa
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, size: 18, color: Colors.blue.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lazy Loading Aktif • ${paginatedState.items.length} item dimuat • Scroll ke bawah untuk auto-load',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List dengan ListView.builder
        ListView.builder(
          key: const Key('paginated_announcements_list_view'),
          controller: _scrollController,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              paginatedState.items.length + (paginatedState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == paginatedState.items.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Memuat pengumuman berikutnya...',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            final item = paginatedState.items[index];
            return AnnouncementItemCard(
              key: ValueKey('paginated_${item.id}'),
              item: item,
              onTap: () {
                context.push('/pengumuman/${item.id}');
              },
            );
          },
        ),
      ],
    );
  }
}
