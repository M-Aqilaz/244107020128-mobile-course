import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcement_detail.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcements.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository({this.items = const [], this.fail = false});

  final List<Announcement> items;
  final bool fail;

  @override
  Future<({List<Announcement> items, Failure? failure})> getAnnouncements() async {
    if (fail) {
      return (
        items: const <Announcement>[],
        failure: const LocalFailure('Database offline (simulasi)'),
      );
    }
    return (items: items, failure: null);
  }

  @override
  Future<({Announcement? item, Failure? failure})> getAnnouncementDetail(String id) async {
    if (fail) {
      return (
        item: null,
        failure: const LocalFailure('Gagal memuat detail (simulasi)'),
      );
    }
    final found = items.where((e) => e.id == id).toList();
    if (found.isEmpty) {
      return (
        item: null,
        failure: const LocalFailure('Data tidak ditemukan'),
      );
    }
    return (item: found.first, failure: null);
  }
}

void main() {
  group('GetAnnouncements Use Case Tests (Domain Layer)', () {
    test('GetAnnouncements meneruskan daftar pengumuman dari repository saat sukses', () async {
      final repo = FakeAnnouncementRepository(items: [
        const Announcement(
          id: '1',
          title: 'Jadwal UTS TI-3H',
          category: 'Akademik',
          date: '01 Oktober 2026',
          body: 'Ujian dimulai jam 08.00 WIB.',
        ),
      ]);

      final result = await GetAnnouncements(repo).call();

      expect(result.failure, isNull);
      expect(result.items.length, 1);
      expect(result.items.first.title, 'Jadwal UTS TI-3H');
      expect(result.items.first.category, 'Akademik');
    });

    test('GetAnnouncements meneruskan failure tanpa melempar exception saat repository gagal', () async {
      final repo = FakeAnnouncementRepository(fail: true);

      final result = await GetAnnouncements(repo).call();

      expect(result.failure, isA<LocalFailure>());
      expect(result.failure?.message, contains('Database offline'));
      expect(result.items, isEmpty);
    });

    test('GetAnnouncementDetail mengembalikan item spesifik berdasarkan ID', () async {
      final repo = FakeAnnouncementRepository(items: [
        const Announcement(
          id: '42',
          title: 'Workshop Clean Architecture Flutter',
          category: 'Perkuliahan',
          date: '10 Oktober 2026',
          body: 'Implementasi SOLID & Separation of Concerns.',
        ),
      ]);

      final result = await GetAnnouncementDetail(repo).call('42');

      expect(result.failure, isNull);
      expect(result.item, isNotNull);
      expect(result.item?.id, '42');
      expect(result.item?.title, 'Workshop Clean Architecture Flutter');
    });
  });
}
