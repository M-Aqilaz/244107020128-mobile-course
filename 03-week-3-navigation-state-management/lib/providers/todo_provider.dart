import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

enum TodoFilter { all, active, completed }

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void setFilter(TodoFilter filter) => state = filter;
}

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

class TodoListNotifier extends Notifier<List<Todo>> {
  int _counter = 0;

  @override
  List<Todo> build() => const [];

  void add(String title) {
    _counter++;
    final newTodo = Todo(
      id: '${DateTime.now().microsecondsSinceEpoch}_$_counter',
      title: title,
    );
    state = [...state, newTodo];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(done: !todo.done) else todo,
    ];
  }

  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void seedInitialData() {
    if (state.isEmpty) {
      state = [
        Todo(id: '1', title: 'Belajar Dasar Flutter & Dart', done: true),
        Todo(id: '2', title: 'Eksperimen Responsive Design Layout', done: true),
        Todo(id: '3', title: 'Implementasi GoRouter & NavigationBar', done: false),
        Todo(id: '4', title: 'Manajemen State Riverpod & AsyncValue', done: false),
      ];
    }
  }
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoFilterProvider);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoFilter.completed:
      return todos.where((todo) => todo.done).toList();
    case TodoFilter.active:
      return todos.where((todo) => !todo.done).toList();
    case TodoFilter.all:
      return todos;
  }
});
