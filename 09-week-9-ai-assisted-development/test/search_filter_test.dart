import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/usecases/search_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SearchAnnouncements searchUseCase;
  late List<Announcement> sampleAnnouncements;

  setUp(() {
    searchUseCase = const SearchAnnouncements();
    sampleAnnouncements = [
      const Announcement(
        id: '1',
        title: 'Jadwal Ujian Tengah Semester (UTS) Ganjil',
        category: 'Akademik',
        date: '01 Oktober 2026',
        body: 'Pelaksanaan ujian tengah semester ganjil dimulai tanggal 15 Oktober 2026.',
      ),
      const Announcement(
        id: '2',
        title: 'Pemeliharaan Server Jaringan Kampus JTI',
        category: 'Infrastruktur',
        date: '30 September 2026',
        body: 'Downtime jaringan internet kampus dan hotspot mahasiswa pada hari Minggu malam.',
      ),
      const Announcement(
        id: '3',
        title: 'Perubahan Ruang Kuliah Pemrograman Mobile TI-3H',
        category: 'Perkuliahan',
        date: '28 September 2026',
        body: 'Praktikum mobile dipindahkan ke Laboratorium Komputasi Cerdas LP-2.',
      ),
    ];
  });

  group('SearchAnnouncements Domain Use Case Unit Tests', () {
    test('1. Mengabaikan huruf besar/kecil (case-insensitive search)', () {
      // Query huruf kecil 'uts' harus cocok dengan 'UTS' di judul
      final resultsLower = searchUseCase(
        announcements: sampleAnnouncements,
        query: 'uts',
      );
      expect(resultsLower.length, equals(1));
      expect(resultsLower.first.id, equals('1'));

      // Query huruf besar 'SERVER' harus cocok dengan 'Server'
      final resultsUpper = searchUseCase(
        announcements: sampleAnnouncements,
        query: 'SERVER',
      );
      expect(resultsUpper.length, equals(1));
      expect(resultsUpper.first.id, equals('2'));
    });

    test('2. Query kosong atau spasi saja mengembalikan semua pengumuman', () {
      final emptyResults = searchUseCase(
        announcements: sampleAnnouncements,
        query: '',
      );
      expect(emptyResults.length, equals(3));

      final whitespaceResults = searchUseCase(
        announcements: sampleAnnouncements,
        query: '     ',
      );
      expect(whitespaceResults.length, equals(3));
    });

    test(
      '3. Query tidak cocok mengembalikan list kosong (trigger empty state)',
      () {
        final noMatchResults = searchUseCase(
          announcements: sampleAnnouncements,
          query: 'zzz-kata-kunci-fiktif-12345',
        );
        expect(noMatchResults, isEmpty);
      },
    );

    test(
      '4. Pencarian mencocokkan kata kunci di judul, body, atau kategori',
      () {
        // Cocok di body: 'Laboratorium'
        final bodyMatch = searchUseCase(
          announcements: sampleAnnouncements,
          query: 'Laboratorium',
        );
        expect(bodyMatch.length, equals(1));
        expect(bodyMatch.first.id, equals('3'));

        // Cocok di category: 'Infrastruktur'
        final categoryMatch = searchUseCase(
          announcements: sampleAnnouncements,
          query: 'Infrastruktur',
        );
        expect(categoryMatch.length, equals(1));
        expect(categoryMatch.first.id, equals('2'));
      },
    );

    test(
      '5. Trimming spasi di depan dan belakang query berjalan dengan benar',
      () {
        final trimmedMatch = searchUseCase(
          announcements: sampleAnnouncements,
          query: '   mobile   ',
        );
        expect(trimmedMatch.length, equals(1));
        expect(trimmedMatch.first.id, equals('3'));
      },
    );
  });
}
