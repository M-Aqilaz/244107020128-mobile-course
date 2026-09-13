import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik ToDo (AsyncValue)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Statistik',
            onPressed: () => ref.invalidate(statsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Memuat data statistik dari server (2s)...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data statistik',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(statsProvider),
                  icon: const Icon(Icons.replay),
                  label: const Text('Coba Lagi (Retry)'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    ref.read(forceErrorProvider.notifier).toggle(false);
                  },
                  child: const Text('Reset Mode Normal'),
                ),
              ],
            ),
          ),
        ),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Item 1: Total Tugas
            _buildStatCard(
              context: context,
              icon: Icons.list_alt,
              title: 'Total Semua Tugas',
              value: '${stats.totalTasks}',
              subtitle: 'Jumlah seluruh item ToDo di memori',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            // Item 2: Status Selesai vs Aktif
            _buildStatCard(
              context: context,
              icon: Icons.task_alt,
              title: 'Tugas Selesai & Aktif',
              value: '${stats.completedTasks} Selesai / ${stats.pendingTasks} Aktif',
              subtitle: 'Distribusi progres pengerjaan',
              color: Colors.teal,
            ),
            const SizedBox(height: 12),
            // Item 3: Persentase Penyelesaian
            _buildStatCard(
              context: context,
              icon: Icons.pie_chart,
              title: 'Persentase Selesai',
              value: '${stats.completionRate.toStringAsFixed(1)}%',
              subtitle: 'Rasio efektivitas penyelesaian',
              color: Colors.indigo,
            ),
            const SizedBox(height: 24),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(forceErrorProvider.notifier).toggle(true);
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Simulasikan Error (Untuk Uji Coba)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withAlpha(40),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
