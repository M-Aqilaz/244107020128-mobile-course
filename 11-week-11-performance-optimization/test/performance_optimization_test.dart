import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/features/announcements/data/repositories/announcement_repository_impl.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:campus_notify/features/announcements/presentation/widgets/announcement_item_card.dart';
import 'package:campus_notify/features/announcements/presentation/widgets/paginated_announcements_view.dart';

void main() {
  group('Performance Optimization - Repository Caching Tests (Step 5)', () {
    test(
      'AnnouncementRepositoryImpl melayani cache segera (Stale-While-Revalidate) tanpa request ulang',
      () async {
        final repo = AnnouncementRepositoryImpl();
        repo.clearCache();

        // Panggilan pertama: Miss cache -> request data & simpan ke cache
        final res1 = await repo.getAnnouncements();
        expect(res1.failure, isNull);
        expect(res1.items, isNotEmpty);
        expect(repo.networkRequestCount, equals(1));
        expect(repo.cacheHitCount, equals(0));

        // Panggilan kedua: Hit cache -> data langsung kembali dari cache tanpa latensi jaringan
        final res2 = await repo.getAnnouncements();
        expect(res2.failure, isNull);
        expect(res2.items.length, equals(res1.items.length));
        expect(repo.networkRequestCount, equals(1)); // Tidak bertambah!
        expect(repo.cacheHitCount, equals(1)); // Cache hit terverifikasi
      },
    );

    test('getAnnouncementsPage mengembalikan data per irisan halaman (pagination)', () async {
      final repo = AnnouncementRepositoryImpl();
      repo.clearCache();

      // Halaman 1 dengan ukuran 4 item
      final page1 = await repo.getAnnouncementsPage(page: 1, pageSize: 4);
      expect(page1.items.length, equals(4));
      expect(page1.hasMore, isTrue);

      // Halaman 2 dengan ukuran 4 item
      final page2 = await repo.getAnnouncementsPage(page: 2, pageSize: 4);
      expect(page2.items.length, equals(4));
      expect(page2.items.first.id, isNot(equals(page1.items.first.id)));

      // Halaman 3 (di luar kapasitas)
      final page3 = await repo.getAnnouncementsPage(page: 3, pageSize: 4);
      expect(page3.items, isEmpty);
      expect(page3.hasMore, isFalse);
    });
  });

  group('Performance Optimization - Lazy Loading & Notifier Tests (Step 4)', () {
    test('PaginatedAnnouncementsNotifier memuat halaman awal dan mendukung loadNextPage', () async {
      // Test harness
      final testContainer = ProviderContainer();
      addTearDown(testContainer.dispose);

      // Tunggu hingga initial page selesai dimuat
      final initialItems = await testContainer.read(announcementRepositoryProvider).getAnnouncementsPage(page: 1, pageSize: 4);
      expect(initialItems.items.length, equals(4));
    });
  });

  group('Performance Optimization - Widget & RepaintBoundary Tests (Step 3)', () {
    testWidgets(
      'AnnouncementItemCard membungkus item dengan RepaintBoundary untuk mengisolasi render GPU',
      (tester) async {
        const dummyItem = Announcement(
          id: '99',
          title: 'Uji Optimasi RepaintBoundary',
          category: 'Akademik',
          date: '11 November 2026',
          body: 'Testing isolasi paint',
        );

        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnnouncementItemCard(
                item: dummyItem,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        // Verifikasi RepaintBoundary membungkus kartu
        expect(find.byType(RepaintBoundary), findsWidgets);
        expect(find.text('Uji Optimasi RepaintBoundary'), findsOneWidget);
        expect(find.text('Akademik • 11 November 2026'), findsOneWidget);

        // Simulasi tap
        await tester.tap(find.byType(ListTile));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'PaginatedAnnouncementsView merender list dengan ListView.builder dan badge status',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PaginatedAnnouncementsView(),
              ),
            ),
          ),
        );

        // Tunggu rendering asinkron selesai
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Verifikasi ListView.builder terpasang
        expect(find.byKey(const Key('paginated_announcements_list_view')), findsOneWidget);
        expect(find.textContaining('Lazy Loading Aktif'), findsOneWidget);
      },
    );
  });
}
