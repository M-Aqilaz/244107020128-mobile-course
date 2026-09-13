import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_provider.dart';

class DetailPage extends ConsumerWidget {
  final String id;
  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final theme = Theme.of(context);

    // Cari todo dengan ID yang cocok
    final todo = todos.cast().firstWhere(
          (t) => t.id == id,
          orElse: () => null,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tugas #$id'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        todo?.done == true ? Icons.check_circle : Icons.pending,
                        color: todo?.done == true
                            ? Colors.green
                            : theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          todo?.title ?? 'Tugas ID $id',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Path Parameter ID', id, theme),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Status Penyelesaian',
                    todo != null
                        ? (todo.done ? 'Selesai (Completed)' : 'Belum Selesai (Active)')
                        : 'Tidak ditemukan di daftar aktif',
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Mekanisme Routing',
                    'GoRouter declarative path: /detail/$id',
                    theme,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FilledButton.tonalIcon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali ke Daftar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
