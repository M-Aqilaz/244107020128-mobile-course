import '../../../../core/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncementDetail {
  const GetAnnouncementDetail(this._repository);

  final AnnouncementRepository _repository;

  Future<({Announcement? item, Failure? failure})> call(String id) {
    return _repository.getAnnouncementDetail(id);
  }
}
