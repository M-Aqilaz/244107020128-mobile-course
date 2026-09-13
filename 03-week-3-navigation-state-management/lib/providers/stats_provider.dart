import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';

class StatsData {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionRate;

  const StatsData({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionRate,
  });
}

class ForceErrorNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle(bool val) => state = val;
}

final forceErrorProvider =
    NotifierProvider<ForceErrorNotifier, bool>(ForceErrorNotifier.new);

class StatsNotifier extends AsyncNotifier<StatsData> {
  @override
  Future<StatsData> build() async {
    final forceError = ref.watch(forceErrorProvider);
    return _fetchStats(forceError);
  }

  Future<StatsData> _fetchStats(bool forceError) async {
    // Simulasi delay network 2 detik sesuai Codelab Langkah #3 & #4
    await Future.delayed(const Duration(seconds: 2));

    if (forceError) {
      throw Exception('Gagal memuat data statistik (Simulasi Error Aktif).');
    }

    final todos = ref.read(todoListProvider);
    final total = todos.length;
    final completed = todos.where((t) => t.done).length;
    final pending = total - completed;
    final rate = total == 0 ? 0.0 : (completed / total) * 100.0;

    return StatsData(
      totalTasks: total,
      completedTasks: completed,
      pendingTasks: pending,
      completionRate: rate,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final forceError = ref.read(forceErrorProvider);
    state = await AsyncValue.guard(() => _fetchStats(forceError));
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, StatsData>(StatsNotifier.new);
