import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcement_detail.dart';
import '../../domain/usecases/get_announcements.dart';

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
