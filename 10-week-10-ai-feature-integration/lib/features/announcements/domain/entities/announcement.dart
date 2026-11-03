class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.body,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String category;
  final String date;
  final String body;
  final bool isRead;
}
