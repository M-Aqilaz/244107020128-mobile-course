import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/providers.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _isEditing = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _initFields(Note note) {
    if (!_initialized) {
      _titleController.text = note.title;
      _bodyController.text = note.body;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(noteDetailProvider(widget.noteId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Catatan #${widget.noteId}'),
        actions: [
          noteAsync.when(
            data: (note) {
              if (note == null) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded),
                tooltip: _isEditing ? 'Simpan Perubahan' : 'Edit Catatan',
                onPressed: () async {
                  if (_isEditing) {
                    final updated = note.copyWith(
                      title: _titleController.text.trim(),
                      body: _bodyController.text.trim(),
                    );
                    await ref.read(notesProvider.notifier).updateNote(updated);
                    setState(() => _isEditing = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Catatan berhasil diperbarui.')),
                      );
                    }
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }

          _initFields(note);

          final formattedDate =
              '${note.updatedAt.day.toString().padLeft(2, '0')}/${note.updatedAt.month.toString().padLeft(2, '0')}/${note.updatedAt.year} ${note.updatedAt.hour.toString().padLeft(2, '0')}:${note.updatedAt.minute.toString().padLeft(2, '0')}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      avatar: Icon(
                        note.dirty ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                        size: 16,
                        color: note.dirty ? theme.colorScheme.error : theme.colorScheme.primary,
                      ),
                      label: Text(
                        note.dirty ? 'Belum Tersinkron' : 'Tersinkron',
                        style: TextStyle(
                          color: note.dirty
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(Icons.access_time_rounded, size: 16),
                      label: Text(formattedDate),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isEditing) ...[
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: 'Judul Catatan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bodyController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Isi Catatan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ] else ...[
                  Text(
                    note.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 28),
                  Text(
                    note.body.isEmpty ? '(Catatan ini tidak memiliki isi)' : note.body,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: note.body.isEmpty
                          ? theme.colorScheme.outline
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
