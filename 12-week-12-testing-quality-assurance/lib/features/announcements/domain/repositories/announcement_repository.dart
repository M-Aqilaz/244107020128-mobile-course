import '../../../../core/failures.dart';
import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<({List<Announcement> items, Failure? failure})> getAnnouncements();
  Future<({Announcement? item, Failure? failure})> getAnnouncementDetail(
    String id,
  );
}

/// Extension metode pengambilan pengumuman per halaman untuk optimasi lazy loading & pagination (Codelab Minggu 11 Step 4 & 5).
/// Dengan extension, seluruh implementasi repository kompatibel tanpa breaking changes pada kelas mock pengujian.
extension PaginatedAnnouncementRepositoryExtension on AnnouncementRepository {
  Future<({List<Announcement> items, bool hasMore, Failure? failure})>
  getAnnouncementsPage({int page = 1, int pageSize = 4}) async {
    final res = await getAnnouncements();
    if (res.failure != null) {
      return (
        items: const <Announcement>[],
        hasMore: false,
        failure: res.failure,
      );
    }
    final start = (page - 1) * pageSize;
    if (start >= res.items.length) {
      return (items: const <Announcement>[], hasMore: false, failure: null);
    }
    final end = (start + pageSize > res.items.length)
        ? res.items.length
        : start + pageSize;
    final paged = res.items.sublist(start, end);
    final hasMore = end < res.items.length;
    return (items: paged, hasMore: hasMore, failure: null);
  }
}
