import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcement_detail.dart';
import '../../domain/usecases/get_announcements.dart';
import '../../domain/usecases/search_announcements.dart';

// Data layer: repository abstraction instance
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl();
});

// Domain layer: Use cases receiving abstractions
final getAnnouncementsUseCaseProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

final getAnnouncementDetailUseCaseProvider = Provider<GetAnnouncementDetail>((
  ref,
) {
  return GetAnnouncementDetail(ref.watch(announcementRepositoryProvider));
});

// Presentation layer: UI state providers
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final usecase = ref.watch(getAnnouncementsUseCaseProvider);
  final result = await usecase.call();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.items;
});

final announcementDetailProvider = FutureProvider.family<Announcement?, String>(
  (ref, id) async {
    final usecase = ref.watch(getAnnouncementDetailUseCaseProvider);
    final result = await usecase.call(id);
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.item;
  },
);

// Domain layer: Search Use Case
final searchAnnouncementsUseCaseProvider = Provider<SearchAnnouncements>((ref) {
  return const SearchAnnouncements();
});

// Presentation layer: Search query state via Riverpod Notifier
class AnnouncementSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }

  void clear() {
    state = '';
  }
}

final announcementSearchQueryProvider =
    NotifierProvider<AnnouncementSearchQueryNotifier, String>(
      AnnouncementSearchQueryNotifier.new,
    );

// Presentation layer: Filtered announcements provider
final filteredAnnouncementsProvider = Provider<AsyncValue<List<Announcement>>>((
  ref,
) {
  final asyncAnnouncements = ref.watch(announcementsProvider);
  final query = ref.watch(announcementSearchQueryProvider);
  final searchUseCase = ref.watch(searchAnnouncementsUseCaseProvider);

  return asyncAnnouncements.whenData((list) {
    return searchUseCase(announcements: list, query: query);
  });
});

// ============================================================================
// PERFORMANCE OPTIMIZATION ADDITIONS (Week 11 Codelab Step 4 & 5)
// ============================================================================

class PaginatedAnnouncementsState {
  const PaginatedAnnouncementsState({
    this.items = const [],
    this.page = 1,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final List<Announcement> items;
  final int page;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  PaginatedAnnouncementsState copyWith({
    List<Announcement>? items,
    int? page,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
  }) {
    return PaginatedAnnouncementsState(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

class PaginatedAnnouncementsNotifier
    extends Notifier<PaginatedAnnouncementsState> {
  @override
  PaginatedAnnouncementsState build() {
    _loadFirstPage();
    return const PaginatedAnnouncementsState(isLoadingMore: true);
  }

  Future<void> _loadFirstPage() async {
    try {
      final repo = ref.read(announcementRepositoryProvider);
      final res = await repo.getAnnouncementsPage(page: 1, pageSize: 4);
      if (res.failure != null) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: res.failure!.message,
        );
        return;
      }
      state = state.copyWith(
        items: res.items,
        page: 2,
        isLoadingMore: false,
        hasMore: res.hasMore,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(announcementRepositoryProvider);
      final res = await repo.getAnnouncementsPage(page: state.page, pageSize: 4);
      if (res.failure != null) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: res.failure!.message,
        );
        return;
      }

      final combined = [...state.items, ...res.items];
      state = state.copyWith(
        items: combined,
        page: state.page + 1,
        isLoadingMore: false,
        hasMore: res.hasMore,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const PaginatedAnnouncementsState(isLoadingMore: true);
    await _loadFirstPage();
  }
}

final paginatedAnnouncementsProvider =
    NotifierProvider<
      PaginatedAnnouncementsNotifier,
      PaginatedAnnouncementsState
    >(PaginatedAnnouncementsNotifier.new);

// Rebuild & Performance Tracking Provider for DevTools verification
class PerformanceMetricsState {
  const PerformanceMetricsState({
    this.homeRebuildCount = 0,
    this.listRebuildCount = 0,
    this.avgFrameTimeMs = 8.3,
    this.jankFrames = 0,
  });

  final int homeRebuildCount;
  final int listRebuildCount;
  final double avgFrameTimeMs;
  final int jankFrames;

  PerformanceMetricsState copyWith({
    int? homeRebuildCount,
    int? listRebuildCount,
    double? avgFrameTimeMs,
    int? jankFrames,
  }) {
    return PerformanceMetricsState(
      homeRebuildCount: homeRebuildCount ?? this.homeRebuildCount,
      listRebuildCount: listRebuildCount ?? this.listRebuildCount,
      avgFrameTimeMs: avgFrameTimeMs ?? this.avgFrameTimeMs,
      jankFrames: jankFrames ?? this.jankFrames,
    );
  }
}

class PerformanceMetricsNotifier extends Notifier<PerformanceMetricsState> {
  @override
  PerformanceMetricsState build() => const PerformanceMetricsState();

  void recordHomeRebuild() {
    state = state.copyWith(homeRebuildCount: state.homeRebuildCount + 1);
  }

  void recordListRebuild() {
    state = state.copyWith(listRebuildCount: state.listRebuildCount + 1);
  }
}

final performanceMetricsProvider =
    NotifierProvider<PerformanceMetricsNotifier, PerformanceMetricsState>(
      PerformanceMetricsNotifier.new,
    );
