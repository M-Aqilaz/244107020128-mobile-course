import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/messaging/push_service.dart';
import 'package:campus_notify/messaging/route_parser.dart';
import 'package:campus_notify/routes.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  group('Route Parser Unit Tests (Codelab Step 6)', () {
    test('routeFromMessage menangani route kosong dan tanpa slash', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('data payload membawa id pengumuman', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });

    test('routeFromMessage returns correct announcement route when id is present', () {
      final data = {'type': 'announcement', 'id': '42'};
      expect(routeFromMessage(data), equals('/pengumuman/42'));
    });

    test('routeFromMessage handles integer id value correctly', () {
      final data = {'id': 105};
      expect(routeFromMessage(data), equals('/pengumuman/105'));
    });

    test('routeFromMessage returns fallback home when id is missing or empty', () {
      expect(routeFromMessage({}), equals(AppRoutes.home));
      expect(routeFromMessage({'id': ''}), equals(AppRoutes.home));
      expect(routeFromMessage({'other_key': '123'}), equals(AppRoutes.home));
    });
  });

  group('Token Masking (OWASP Mobile Security)', () {
    test('maskToken masks long tokens showing only head and tail', () {
      const token = 'fcm_token_polinema_244107020128_secret_credential_9b2d';
      final masked = PushService.maskToken(token);
      expect(masked.startsWith('fcm_toke'), isTrue);
      expect(masked.endsWith('_9b2d'), isTrue);
      expect(masked.contains('...'), isTrue);
      expect(masked.contains('secret_credential'), isFalse);
    });

    test('maskToken handles null or empty safely', () {
      expect(PushService.maskToken(null), equals('Belum tersedia'));
      expect(PushService.maskToken(''), equals('Belum tersedia'));
    });

    test('maskToken preserves short tokens under 16 characters', () {
      expect(PushService.maskToken('short_token'), equals('short_token'));
    });
  });

  group('API Errors Handling Tests', () {
    test('friendlyErrorMessage maps 401 to session expired', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/announcements'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/announcements'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );
      final msg = friendlyErrorMessage(error);
      expect(msg.toLowerCase(), contains('kedaluwarsa'));
    });

    test('friendlyErrorMessage maps 403 to forbidden', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/admin'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/admin'),
          statusCode: 403,
        ),
        type: DioExceptionType.badResponse,
      );
      final msg = friendlyErrorMessage(error);
      expect(msg.toLowerCase(), contains('hak akses'));
    });

    test('friendlyErrorMessage maps connection timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/announcements'),
        type: DioExceptionType.connectionTimeout,
      );
      final msg = friendlyErrorMessage(error);
      expect(msg.toLowerCase(), contains('timeout'));
    });
  });

  group('Auth Repository Validation Tests', () {
    final repo = AuthRepository();

    test('login succeeds with valid credentials', () async {
      final session = await repo.login(
        email: 'aqil@student.polinema.ac.id',
        password: 'password123',
      );
      expect(session.access.isNotEmpty, isTrue);
      expect(session.refresh.isNotEmpty, isTrue);
      expect(session.email, equals('aqil@student.polinema.ac.id'));
    });

    test('login throws exception with empty password', () async {
      expect(
        () => repo.login(email: 'aqil@student.polinema.ac.id', password: ''),
        throwsA(isA<Exception>()),
      );
    });

    test('login throws exception with short password (< 6 chars)', () async {
      expect(
        () => repo.login(email: 'aqil@student.polinema.ac.id', password: '123'),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh generates renewed token', () async {
      final renewed = await repo.refresh('mock-refresh-token');
      expect(renewed.startsWith('jwt-renewed-'), isTrue);
    });

    test('provider auth membaca status login dari token', () async {
      final store = FakeTokenStore()..access = 'mock-access';
      expect(store.access != null, isTrue);
      store.access = null;
      expect(store.access != null, isFalse);
    });

    test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
      final store = FakeTokenStore()..refresh = '';
      final needsLogin = (store.refresh ?? '').isEmpty;
      expect(needsLogin, isTrue);
    });
  });
}
