import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodos = ref.watch(filteredTodoListProvider);
    final currentFilter = ref.watch(todoFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas ToDo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            tooltip: 'Isi Contoh Data',
            onPressed: () {
              ref.read(todoListProvider.notifier).seedInitialData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (Refactoring Challenge)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: currentFilter == TodoFilter.all,
                  onSelected: (_) {
                    ref
                        .read(todoFilterProvider.notifier)
                        .setFilter(TodoFilter.all);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Aktif'),
                  selected: currentFilter == TodoFilter.active,
                  onSelected: (_) {
                    ref
                        .read(todoFilterProvider.notifier)
                        .setFilter(TodoFilter.active);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Selesai'),
                  selected: currentFilter == TodoFilter.completed,
                  onSelected: (_) {
                    ref
                        .read(todoFilterProvider.notifier)
                        .setFilter(TodoFilter.completed);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List View
          Expanded(
            child: filteredTodos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.checklist_rtl,
                          size: 64,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada tugas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showAddDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Tugas Baru'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return TodoTile(
                        todo: todo,
                        onToggle: (_) {
                          ref.read(todoListProvider.notifier).toggle(todo.id);
                        },
                        onDelete: () {
                          ref.read(todoListProvider.notifier).remove(todo.id);
                        },
                        onTap: () {
                          context.push('/detail/${todo.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tugas Baru'),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Tugas Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Misal: Kerjakan PR Minggu 3',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              ref.read(todoListProvider.notifier).add(val.trim());
              Navigator.pop(dialogContext);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(todoListProvider.notifier).add(controller.text.trim());
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
