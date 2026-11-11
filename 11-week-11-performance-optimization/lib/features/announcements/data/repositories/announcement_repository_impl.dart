import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl();

  // Data sumber pengumuman kampus Polinema (dataset yang mencukupi untuk lazy loading & infinite scroll)
  static final List<Map<String, dynamic>> _mockData = [
    {
      'id': '1',
      'title': 'Jadwal Ujian Tengah Semester (UTS) Semester Ganjil',
      'category': 'Akademik',
      'date': '01 Oktober 2026, 08:00 WIB',
      'body':
          'Diberitahukan kepada seluruh mahasiswa Jurusan Teknologi Informasi Polinema bahwa jadwal pelaksanaan Ujian Tengah Semester (UTS) dapat diakses melalui portal SIAKAD. Mahasiswa diwajibkan membawa kartu ujian dan mengenakan seragam sesuai ketentuan.',
      'is_read': 0,
    },
    {
      'id': '2',
      'title': 'Pemeliharaan Server Jaringan Kampus JTI',
      'category': 'Infrastruktur',
      'date': '30 September 2026, 17:30 WIB',
      'body':
          'Akan dilakukan perbaikan berkala pada server lokal lab komputasi dan hotspot area Gedung Sipil & TI pada hari Sabtu pukul 22.00–04.00 WIB. Selama durasi tersebut, akses internet lokal kampus akan offline sementara.',
      'is_read': 0,
    },
    {
      'id': '3',
      'title': 'Perubahan Ruang Kuliah Pemrograman Mobile',
      'category': 'Perkuliahan',
      'date': '29 September 2026, 11:15 WIB',
      'body':
          'Kuliah praktikum Pemrograman Mobile Kelas TI-3H hari ini dipindahkan ke Ruang Lab Komputer 2 (LPR 2) Lantai 7 Gedung Jurusan Teknologi Informasi mulai pukul 13.00 WIB. Harap hadir tepat waktu membawa laptop dan project tugas.',
      'is_read': 0,
    },
    {
      'id': '4',
      'title': 'Pendaftaran Program Magang Bersertifikat Industri (MSIB)',
      'category': 'Akademik',
      'date': '28 September 2026, 09:00 WIB',
      'body':
          'Pendaftaran program MSIB batch 8 telah dibuka untuk mahasiswa semester 5 dan 7. Persiapkan CV, portofolio proyek mobile/web, dan transkrip nilai akademik sebelum batas akhir pendaftaran.',
      'is_read': 0,
    },
    {
      'id': '5',
      'title': 'Workshop Flutter DevTools & Performance Optimization',
      'category': 'Workshop',
      'date': '27 September 2026, 14:00 WIB',
      'body':
          'Laboratorium Mobile Application JTI mengadakan workshop intensif optimasi performa Flutter menggunakan DevTools CPU Flame Chart, Heap Memory Profiler, dan teknik repainting boundary.',
      'is_read': 0,
    },
    {
      'id': '6',
      'title': 'Sosialisasi Tugas Akhir & Skripsi D-IV Teknik Informatika',
      'category': 'Akademik',
      'date': '26 September 2026, 10:00 WIB',
      'body':
          'Sosialisasi alur pengajuan judul proposal skripsi dan syarat kelulusan mahasiswa tingkat akhir akan dilaksanakan di Aula Gedung Graha Polinema.',
      'is_read': 0,
    },
    {
      'id': '7',
      'title': 'Update Layanan Repository Git Kampus (GitLab JTI)',
      'category': 'Infrastruktur',
      'date': '25 September 2026, 16:00 WIB',
      'body':
          'Server GitLab kampus telah di-upgrade untuk mendukung resource CI/CD runner yang lebih cepat bagi tugas mata kuliah berbasis microservices dan mobile dev.',
      'is_read': 0,
    },
    {
      'id': '8',
      'title': 'Kompetisi Pemrograman & UI/UX Nasional KMIPN 2026',
      'category': 'Prestasi',
      'date': '24 September 2026, 13:30 WIB',
      'body':
          'Seleksi internal perwakilan Politeknik Negeri Malang untuk ajang Kompetisi Mahasiswa Informatika Politeknik Nasional (KMIPN) kategori Cipta Inovasi dan Pengembangan Aplikasi Mobile.',
      'is_read': 0,
    },
  ];

  // In-memory cache layer (Optimasi Jaringan Caching: Stale-While-Revalidate - Step 5 Codelab)
  List<Announcement>? _memoryCache;
  DateTime? _lastCacheTime;
  int _networkRequestCount = 0;
  int _cacheHitCount = 0;

  int get networkRequestCount => _networkRequestCount;
  int get cacheHitCount => _cacheHitCount;

  void clearCache() {
    _memoryCache = null;
    _lastCacheTime = null;
  }

  @override
  Future<({List<Announcement> items, Failure? failure})>
  getAnnouncements() async {
    // 1. Cek apakah ada cache valid (Stale-While-Revalidate strategy)
    final now = DateTime.now();
    if (_memoryCache != null &&
        _lastCacheTime != null &&
        now.difference(_lastCacheTime!) < const Duration(seconds: 60)) {
      _cacheHitCount++;
      return (items: List<Announcement>.unmodifiable(_memoryCache!), failure: null);
    }

    try {
      _networkRequestCount++;
      // Simulasi latency jaringan
      await Future.delayed(const Duration(milliseconds: 40));
      final items = _mockData
          .map((data) => AnnouncementModel.fromMap(data).toEntity())
          .toList();

      // Simpan ke cache lokal
      _memoryCache = items;
      _lastCacheTime = now;

      return (items: items, failure: null);
    } catch (e) {
      if (_memoryCache != null) {
        // Fallback offline ke cache lokal
        return (items: List<Announcement>.unmodifiable(_memoryCache!), failure: null);
      }
      return (
        items: const <Announcement>[],
        failure: LocalFailure('Gagal memuat daftar pengumuman: $e'),
      );
    }
  }

  @override
  Future<({Announcement? item, Failure? failure})> getAnnouncementDetail(
    String id,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 30));
      final found = _mockData.firstWhere(
        (data) => data['id'].toString() == id,
        orElse: () => _mockData.first,
      );
      final entity = AnnouncementModel.fromMap(found).toEntity();
      return (item: entity, failure: null);
    } catch (e) {
      return (
        item: null,
        failure: LocalFailure('Pengumuman dengan ID $id tidak ditemukan: $e'),
      );
    }
  }

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
