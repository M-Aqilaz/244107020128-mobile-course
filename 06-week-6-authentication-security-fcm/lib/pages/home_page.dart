import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../providers/push_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _showFullToken = false;
  Map<String, dynamic>? _activeForegroundBanner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScenarioParameters();
      _listenToForeground();
    });
  }

  void _checkScenarioParameters() {
    final uri = Uri.base.toString();
    if (uri.contains('scenario=notification')) {
      setState(() {
        _activeForegroundBanner = {
          'title': 'Pengumuman Baru: Jadwal UTS Semester Ganjil',
          'body': 'Diberitahukan kepada mahasiswa TI bahwa jadwal UTS telah dirilis.',
          'route': '/pengumuman/1',
        };
      });
    } else if (uri.contains('scenario=refresh')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.teal,
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'HTTP 401 Terdeteksi: Token access kedaluwarsa. Berhasil diperbarui otomatis via Refresh Token!',
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 8),
        ),
      );
    }
  }

  void _listenToForeground() {
    final pushService = ref.read(pushServiceProvider);
    pushService.foregroundMessages.listen((msg) {
      if (mounted) {
        setState(() {
          _activeForegroundBanner = msg;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fcmToken = ref.watch(fcmTokenProvider);
    final isSubscribed = ref.watch(topicSubscribedProvider);
    final emailAsync = ref.watch(userEmailProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campus Notify',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Politeknik Negeri Malang',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foreground Banner simulasi jika ada pesan masuk
            if (_activeForegroundBanner != null) ...[
              Card(
                color: Colors.amber.shade100,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber.shade700, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          color: Colors.amber.shade900, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _activeForegroundBanner!['title'] ?? 'Notifikasi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.brown.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeForegroundBanner!['body'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.brown.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _activeForegroundBanner = null;
                                    });
                                  },
                                  child: const Text('Tutup'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber.shade800,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text('Lihat Detail'),
                                  onPressed: () {
                                    final route =
                                        _activeForegroundBanner!['route']
                                            as String?;
                                    setState(() {
                                      _activeForegroundBanner = null;
                                    });
                                    if (route != null) {
                                      context.push(route);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Profil Mahasiswa Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.school_rounded,
                        size: 30,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Muhammad Aqil Azami',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NIM: 244107020128 • Kelas: TI-3H',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          emailAsync.when(
                            data: (email) => Text(
                              email,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            loading: () => const Text('Memuat session...'),
                            error: (err, stack) => const Text('Offline mode'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Token Keamanan FCM Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.vpn_key_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'FCM Device Token (Keystore)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade600),
                          ),
                          child: Text(
                            'Encrypted',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sesuai OWASP Mobile Security, token disamarkan (masked) di tampilan UI agar tidak bocor via screen-sharing atau logcat.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              _showFullToken
                                  ? (fcmToken ?? 'Belum ada token')
                                  : PushService.maskToken(fcmToken),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _showFullToken
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                            ),
                            tooltip: _showFullToken
                                ? 'Samarkan Token'
                                : 'Tampilkan Penuh',
                            onPressed: () {
                              setState(() {
                                _showFullToken = !_showFullToken;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            tooltip: 'Salin Token',
                            onPressed: () {
                              if (fcmToken != null) {
                                Clipboard.setData(
                                    ClipboardData(text: fcmToken));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Token disalin ke clipboard!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Topic Subscription & Switch Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.campaign_outlined,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                title: const Text(
                  'Topik: pengumuman-kampus',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  isSubscribed
                      ? 'Status: Aktif menerima broadcast se-jurusan'
                      : 'Status: Berhenti berlangganan siaran kampus',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSubscribed ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                value: isSubscribed,
                onChanged: (value) async {
                  ref.read(topicSubscribedProvider.notifier).setSubscribed(value);
                  final push = ref.read(pushServiceProvider);
                  if (value) {
                    await push.subscribeToTopic('pengumuman-kampus');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Berhasil berlangganan ke topik "pengumuman-kampus"',
                          ),
                        ),
                      );
                    }
                  } else {
                    await push.unsubscribeFromTopic('pengumuman-kampus');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Berhenti langganan dari topik "pengumuman-kampus"',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Panel Pengujian Interaktif (Praktikum & Codelab)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.science_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Panel Pengujian Praktikum',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          key: const Key('btn_simulate_push'),
                          icon: const Icon(Icons.notifications_active, size: 18),
                          label: const Text('Simulasi Push Masuk (Foreground)'),
                          onPressed: () {
                            ref.read(pushServiceProvider).simulateIncomingPush(
                                  title:
                                      'Pengumuman Baru: Jadwal UTS Semester Ganjil',
                                  body:
                                      'Diberitahukan kepada mahasiswa TI bahwa jadwal UTS telah dirilis.',
                                  route: '/pengumuman/1',
                                );
                          },
                        ),
                        OutlinedButton.icon(
                          key: const Key('btn_simulate_refresh'),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Simulasi 401 Auto-Refresh Token'),
                          onPressed: () async {
                            final newToken = await ref
                                .read(authStateProvider.notifier)
                                .simulateRefresh();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.teal.shade700,
                                  content: Text(
                                    'Token diperbarui: ${newToken.substring(0, 15)}... (Auto-Refresh Berhasil)',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Pengumuman Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pengumuman Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '3 Pengumuman',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _buildAnnouncementItem(
              context,
              id: '1',
              title: 'Jadwal Ujian Tengah Semester (UTS) Semester Ganjil',
              category: 'Akademik',
              date: '01 Oktober 2026',
              icon: Icons.assignment_rounded,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),

            _buildAnnouncementItem(
              context,
              id: '2',
              title: 'Pemeliharaan Server Jaringan Kampus JTI',
              category: 'Infrastruktur',
              date: '30 September 2026',
              icon: Icons.cloud_sync_rounded,
              color: Colors.orange,
            ),
            const SizedBox(height: 8),

            _buildAnnouncementItem(
              context,
              id: '3',
              title: 'Perubahan Ruang Kuliah Pemrograman Mobile',
              category: 'Perkuliahan',
              date: '29 September 2026',
              icon: Icons.room_rounded,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem(
    BuildContext context, {
    required String id,
    required String title,
    required String category,
    required String date,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$category • $date',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {
          context.push('/pengumuman/$id');
        },
      ),
    );
  }
}
