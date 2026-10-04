import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  Map<String, String> _getAnnouncementData(String id) {
    switch (id) {
      case '1':
        return {
          'title': 'Jadwal Ujian Tengah Semester (UTS) Semester Ganjil',
          'category': 'Akademik',
          'date': '01 Oktober 2026, 08:00 WIB',
          'body':
              'Diberitahukan kepada seluruh mahasiswa Jurusan Teknologi Informasi Polinema bahwa jadwal pelaksanaan Ujian Tengah Semester (UTS) dapat diakses melalui portal SIAKAD. Mahasiswa diwajibkan membawa kartu ujian dan mengenakan seragam sesuai ketentuan.',
        };
      case '2':
        return {
          'title': 'Pemeliharaan Server Jaringan Kampus JTI',
          'category': 'Infrastruktur',
          'date': '30 September 2026, 17:30 WIB',
          'body':
              'Akan dilakukan perbaikan berkala pada server lokal lab komputasi dan hotspot area Gedung Sipil & TI pada hari Sabtu pukul 22.00–04.00 WIB. Selama durasi tersebut, akses internet lokal kampus akan offline sementara.',
        };
      case '3':
      default:
        return {
          'title': 'Perubahan Ruang Kuliah Pemrograman Mobile',
          'category': 'Perkuliahan',
          'date': '29 September 2026, 11:15 WIB',
          'body':
              'Kuliah praktikum Pemrograman Mobile Kelas TI-3H hari ini dipindahkan ke Ruang Lab Komputer 2 (LPR 2) Lantai 7 Gedung Jurusan Teknologi Informasi mulai pukul 13.00 WIB. Harap hadir tepat waktu membawa laptop dan project tugas.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _getAnnouncementData(id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pengumuman #$id'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.campaign_rounded, size: 16),
                  label: Text(data['category']!),
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.link_rounded, size: 16),
                  label: const Text('FCM Deep Link'),
                  backgroundColor:
                      theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              data['title']!,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Date
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  data['date']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // Body
            Text(
              data['body']!,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),

            // Payload Inspector Card
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.code_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Inspeksi Payload FCM (Hybrid)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Notification: title="${data['title']}"\n• Data Payload: {route: "/pengumuman/$id", id: "$id"}\n• Deep link GoRouter: ${AppRoutes.announcement(id)}',
                      style: const TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
