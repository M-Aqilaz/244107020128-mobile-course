import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/auth/data/datasources/token_store.dart';
import 'package:campus_notify/features/auth/presentation/pages/login_page.dart';
import 'package:campus_notify/features/auth/presentation/providers/auth_providers.dart';
import 'package:campus_notify/features/home/presentation/pages/home_page.dart';

class InMemoryTokenStore extends TokenStore {
  String? _access;
  String? _refresh;
  String? _email;

  @override
  Future<void> save({
    required String access,
    required String refresh,
    String? email,
  }) async {
    _access = access;
    _refresh = refresh;
    _email = email;
  }

  @override
  Future<String?> readAccess() async => _access;

  @override
  Future<String?> readRefresh() async => _refresh;

  @override
  Future<String?> readEmail() async => _email;

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
    _email = null;
  }
}

void main() {
  testWidgets(
    'LoginPage renders cleanly without direct platform dependencies',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          ],
          child: const MaterialApp(home: LoginPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Campus Notify'), findsOneWidget);
      expect(
        find.text('Portal Notifikasi & Pengumuman Mahasiswa'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Masuk ke Aplikasi'), findsOneWidget);
    },
  );

  testWidgets('LoginPage validates invalid inputs on submit via LoginUseCase', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(InMemoryTokenStore())],
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Clear email field to trigger validation error in LoginUseCase
    await tester.enterText(find.widgetWithText(TextField, 'Email Kampus'), '');
    await tester.pump();

    // Tap login button
    await tester.tap(find.text('Masuk ke Aplikasi'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Email tidak valid'), findsOneWidget);
  });

  testWidgets(
    'HomePage displays student profile, Clean Arch tag, and announcements',
    (tester) async {
      final store = InMemoryTokenStore();
      await store.save(
        access: 'mock-access',
        refresh: 'mock-refresh',
        email: 'aqil@student.polinema.ac.id',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [tokenStoreProvider.overrideWithValue(store)],
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify student identity
      expect(find.text('Muhammad Aqil Azami'), findsOneWidget);
      expect(find.textContaining('244107020128'), findsOneWidget);
      expect(find.textContaining('TI-3H'), findsOneWidget);

      // Verify Clean Architecture tags & FCM token section
      expect(find.text('Clean Arch'), findsOneWidget);
      expect(find.text('FCM Device Token (Keystore)'), findsOneWidget);

      // Verify interactive simulation buttons
      expect(find.byKey(const Key('btn_simulate_push')), findsOneWidget);
      expect(find.byKey(const Key('btn_simulate_refresh')), findsOneWidget);

      // Verify announcements from Clean Architecture repository
      expect(
        find.textContaining('Jadwal Ujian Tengah Semester'),
        findsOneWidget,
      );
    },
  );
}
