import '../../../../core/failures.dart';
import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<({List<Announcement> items, Failure? failure})> getAnnouncements();
  Future<({Announcement? item, Failure? failure})> getAnnouncementDetail(String id);
}
