import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/in_memory_task_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/task_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return InMemoryTaskRepository();
});

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.watch(taskRepositoryProvider));
});

class TaskListState {
  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<String> tasks;
  final bool isLoading;
  final String? errorMessage;

  TaskListState copyWith({
    List<String>? tasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TaskListNotifier extends Notifier<TaskListState> {
  @override
  TaskListState build() {
    // Muat data awal secara asinkron
    _loadInitial();
    return const TaskListState(isLoading: true);
  }

  Future<void> _loadInitial() async {
    try {
      final service = ref.read(taskServiceProvider);
      final list = await service.loadTasks();
      state = state.copyWith(tasks: list, isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addTask(String title) async {
    try {
      final service = ref.read(taskServiceProvider);
      await service.addTask(title);
      final updatedList = await service.loadTasks();
      state = state.copyWith(tasks: updatedList, errorMessage: null);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> removeTask(String title) async {
    try {
      final service = ref.read(taskServiceProvider);
      await service.removeTask(title);
      final updatedList = await service.loadTasks();
      state = state.copyWith(tasks: updatedList);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final taskListNotifierProvider =
    NotifierProvider<TaskListNotifier, TaskListState>(TaskListNotifier.new);
