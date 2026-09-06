import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets('Memverifikasi tampilan profil mahasiswa', (WidgetTester tester) async {
    // Build aplikasi profil mahasiswa
    await tester.pumpWidget(const MyApp());

    // Memverifikasi teks nama dan NIM mahasiswa
    expect(find.text('Profil Mahasiswa'), findsOneWidget);
    expect(find.text('Muhammad Aqil Azami'), findsOneWidget);
    expect(find.text('NIM: 244107020128'), findsOneWidget);
    expect(find.text('Teknik Informatika'), findsOneWidget);

    // Memverifikasi ikon akademik
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.byIcon(Icons.badge), findsOneWidget);
  });
}
