class Todo {
  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.done = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    bool? done,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
