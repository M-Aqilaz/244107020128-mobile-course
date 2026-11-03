import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:campus_notify/features/auth/data/datasources/token_store.dart';
import 'package:campus_notify/features/auth/presentation/providers/auth_providers.dart';
import 'package:campus_notify/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAnnouncementRepo implements AnnouncementRepository {
  @override
  Future<({List<Announcement> items, Failure? failure})>
  getAnnouncements() async {
    return (
      items: const [
        Announcement(
          id: '1',
          title: 'Jadwal Ujian Tengah Semester (UTS)',
          category: 'Akademik',
          date: '01 Oktober 2026',
          body: 'Jadwal UTS ganjil sudah dirilis di SIAKAD.',
        ),
        Announcement(
          id: '2',
          title: 'Pemeliharaan Server Jaringan Kampus',
          category: 'Infrastruktur',
          date: '30 September 2026',
          body: 'Maintenance server pada hari Minggu.',
        ),
      ],
      failure: null,
    );
  }

  @override
  Future<({Announcement? item, Failure? failure})> getAnnouncementDetail(
    String id,
  ) async {
    return (
      item: const Announcement(
        id: '1',
        title: 'Jadwal Ujian Tengah Semester (UTS)',
        category: 'Akademik',
        date: '01 Oktober 2026',
        body: 'Jadwal UTS ganjil sudah dirilis di SIAKAD.',
      ),
      failure: null,
    );
  }
}

class FakeTokenStore extends TokenStore {
  @override
  Future<String?> readAccess() async => 'fake-access-token';
  @override
  Future<String?> readRefresh() async => 'fake-refresh-token';
  @override
  Future<String?> readEmail() async => 'aqil@student.polinema.ac.id';
  @override
  Future<void> save({
    required String access,
    required String refresh,
    String? email,
  }) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets(
    'Search Bar memfilter pengumuman dan menampilkan empty state saat tak cocok',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStoreProvider.overrideWithValue(FakeTokenStore()),
            announcementRepositoryProvider.overrideWithValue(
              MockAnnouncementRepo(),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      // Initial state: fetch announcements
      await tester.pumpAndSettle();

      // Pastikan search bar ada di layar
      final searchInputFinder = find.byKey(
        const Key('search_announcements_input'),
      );
      expect(searchInputFinder, findsOneWidget);

      // Pastikan kedua pengumuman awal tampil
      expect(find.text('Jadwal Ujian Tengah Semester (UTS)'), findsOneWidget);
      expect(find.text('Pemeliharaan Server Jaringan Kampus'), findsOneWidget);

      // 1. Ketik query pencarian 'UTS'
      await tester.enterText(searchInputFinder, 'UTS');
      await tester.pumpAndSettle();

      // Pengumuman UTS tetap tampil, pengumuman Server menghilang
      expect(find.text('Jadwal Ujian Tengah Semester (UTS)'), findsOneWidget);
      expect(find.text('Pemeliharaan Server Jaringan Kampus'), findsNothing);

      // 2. Ketik query yang tidak cocok sama sekali
      await tester.enterText(searchInputFinder, 'zzz-tak-ada-data');
      await tester.pumpAndSettle();

      // Verifikasi Empty State muncul
      expect(find.byKey(const Key('search_empty_state')), findsOneWidget);
      expect(find.text('Pengumuman Tidak Ditemukan'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('search_empty_state')),
          matching: find.textContaining('zzz-tak-ada-data'),
        ),
        findsOneWidget,
      );

      // 3. Tekan tombol Reset Pencarian di Empty State
      final resetBtnFinder = find.byKey(const Key('btn_reset_search_empty'));
      expect(resetBtnFinder, findsOneWidget);
      await tester.tap(resetBtnFinder);
      await tester.pumpAndSettle();

      // Kedua pengumuman kembali tampil normal
      expect(find.text('Jadwal Ujian Tengah Semester (UTS)'), findsOneWidget);
      expect(find.text('Pemeliharaan Server Jaringan Kampus'), findsOneWidget);
      expect(find.byKey(const Key('search_empty_state')), findsNothing);
    },
  );
}
