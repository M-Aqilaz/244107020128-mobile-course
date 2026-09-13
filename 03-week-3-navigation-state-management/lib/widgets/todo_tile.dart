import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: todo.done
              ? theme.colorScheme.outlineVariant.withAlpha(80)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: todo.done,
          onChanged: onToggle,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: todo.done ? TextDecoration.lineThrough : null,
            color: todo.done
                ? theme.colorScheme.onSurface.withAlpha(128)
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'ID: ${todo.id}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              tooltip: 'Detail Tugas',
              onPressed: onTap,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: theme.colorScheme.error, size: 22),
              tooltip: 'Hapus Tugas',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
