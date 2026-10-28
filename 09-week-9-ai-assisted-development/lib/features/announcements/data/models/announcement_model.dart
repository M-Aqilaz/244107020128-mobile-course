import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.category,
    required super.date,
    required super.body,
    super.isRead = false,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Umum',
      date: map['date'] as String? ?? '',
      body: map['body'] as String? ?? '',
      isRead: map['is_read'] == true || map['is_read'] == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'date': date,
    'body': body,
    'is_read': isRead ? 1 : 0,
  };

  Announcement toEntity() => Announcement(
    id: id,
    title: title,
    category: category,
    date: date,
    body: body,
    isRead: isRead,
  );
}
