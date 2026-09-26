import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider).value ?? false;
    final isOffline = ref.watch(forceOfflineProvider).value ?? false;
    final lastOpenedAsync = ref.watch(lastOpenedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Preferensi'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Preferensi Aplikasi (SharedPreferences)',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          SwitchListTile(
            title: const Text('Mode Gelap (Dark Mode)'),
            subtitle: const Text('Menyimpan tema pilihan ke SharedPreferences'),
            secondary: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            ),
            value: isDark,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Simulasi Offline-First',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          SwitchListTile(
            title: const Text('Simulasi Mode Pesawat (Offline)'),
            subtitle: const Text('Menonaktifkan akses jaringan secara deterministik'),
            secondary: Icon(
              isOffline ? Icons.flight_takeoff_rounded : Icons.flight_land_rounded,
              color: isOffline ? theme.colorScheme.error : null,
            ),
            value: isOffline,
            onChanged: (_) =>
                ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Informasi Sistem',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('Waktu Terakhir Dibuka'),
            subtitle: lastOpenedAsync.when(
              data: (val) {
                if (val == null) return const Text('Baru pertama kali dibuka');
                final dt = DateTime.tryParse(val);
                if (dt == null) return Text(val);
                return Text(
                  '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}',
                );
              },
              loading: () => const Text('Memuat...'),
              error: (_, _) => const Text('-'),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: theme.colorScheme.surfaceContainerHighest,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Catatan Arsitektur',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'SharedPreferences hanya digunakan untuk menyimpan pengaturan primitif kecil seperti tema dan riwayat buka. Koleksi data catatan terstruktur seluruhnya disimpan dalam database SQLite lokal (sqflite).',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
