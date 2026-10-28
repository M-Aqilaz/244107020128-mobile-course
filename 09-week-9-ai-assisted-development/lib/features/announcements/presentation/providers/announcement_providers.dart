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

// Presentation layer: Search query state via Riverpod 3 Notifier
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
