import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';
import 'package:week4_api/pages/post_list_page.dart';
import 'package:week4_api/pages/post_detail_page.dart';
import 'package:dio/dio.dart';

class MockPostRepo extends PostRepository {
  MockPostRepo(this.posts) : super(Dio());
  final List<Post> posts;

  @override
  Future<List<Post>> fetchPosts() async => posts;

  @override
  Future<Post> fetchPostDetail(int id) async =>
      posts.firstWhere((p) => p.id == id);
}

class MockCommentRepo extends CommentRepository {
  MockCommentRepo(this.comments) : super(Dio());
  final List<Comment> comments;

  @override
  Future<List<Comment>> fetchComments(int postId) async => comments;
}

void main() {
  testWidgets('PostListPage menampilkan list post dengan benar', (tester) async {
    final mockPosts = [
      const Post(userId: 1, id: 1, title: 'Judul Post Pertama', body: 'Isi post pertama di sini'),
      const Post(userId: 1, id: 2, title: 'Judul Post Kedua', body: 'Isi post kedua di sini'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(MockPostRepo(mockPosts)),
        ],
        child: const MaterialApp(
          home: PostListPage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Judul Post Pertama'), findsOneWidget);
    expect(find.text('Judul Post Kedua'), findsOneWidget);
  });

  testWidgets('PostDetailPage menampilkan detail post dan komentar', (tester) async {
    const post = Post(userId: 1, id: 99, title: 'Detail Test', body: 'Konten detail test');
    final comments = [
      const Comment(postId: 99, id: 1, name: 'Pengguna 1', email: 'user1@test.com', body: 'Komentar satu'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(MockPostRepo([post])),
          commentRepositoryProvider.overrideWithValue(MockCommentRepo(comments)),
        ],
        child: const MaterialApp(
          home: PostDetailPage(postId: 99),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Detail Post #99'), findsOneWidget);
    expect(find.text('Detail Test'), findsOneWidget);
    expect(find.text('Konten detail test'), findsOneWidget);
    expect(find.text('Komentar satu'), findsOneWidget);
  });
}
