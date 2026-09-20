import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment Model Tests', () {
    test('fromJson aman terhadap field yang kosong dan null', () {
      final json = <String, dynamic>{
        'id': 101,
      };

      final comment = Comment.fromJson(json);

      expect(comment.id, 101);
      expect(comment.postId, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('fromJson berhasil memetakan payload JSON valid', () {
      final json = <String, dynamic>{
        'postId': 1,
        'id': 5,
        'name': 'Budi',
        'email': 'budi@example.com',
        'body': 'Artikel yang sangat bagus!',
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 1);
      expect(comment.id, 5);
      expect(comment.name, 'Budi');
      expect(comment.email, 'budi@example.com');
      expect(comment.body, 'Artikel yang sangat bagus!');
    });

    test('toJson menghasilkan Map yang sesuai', () {
      const comment = Comment(
        postId: 2,
        id: 10,
        name: 'Siti',
        email: 'siti@example.com',
        body: 'Komentar pengujian',
      );

      final map = comment.toJson();

      expect(map['postId'], 2);
      expect(map['id'], 10);
      expect(map['name'], 'Siti');
      expect(map['email'], 'siti@example.com');
      expect(map['body'], 'Komentar pengujian');
    });
  });
}
