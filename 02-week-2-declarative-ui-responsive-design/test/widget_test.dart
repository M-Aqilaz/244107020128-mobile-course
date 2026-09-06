import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we2/main.dart';

void main() {
  testWidgets('Dashboard satu kolom di layar sempit (< 600)', (tester) async {
    // Simulasi ukuran layar sempit mobile: 400x800
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());

    // Verifikasi header profil muncul
    expect(find.text('Muhammad Aqil Azami'), findsOneWidget);
    expect(find.text('NIM: 244107020128 | Kelas: TI-3H'), findsOneWidget);

    // Verifikasi 4 kartu metrik akademik muncul
    expect(find.text('SKS Selesai'), findsOneWidget);
    expect(find.text('IPK Kumulatif'), findsOneWidget);
    expect(find.text('Kehadiran Kuliah'), findsOneWidget);
    expect(find.text('Status Akademik'), findsOneWidget);

    // Di layar 400px (1 kolom), lebar tiap card mendekati lebar layar (sekitar 368px dengan padding)
    final cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(4));
    final width = tester.getSize(cardFinder.first).width;
    expect(width, lessThan(600));
    expect(width, greaterThan(300));
  });

  testWidgets('Dashboard dua kolom di layar lebar (>= 600)', (tester) async {
    // Simulasi ukuran layar lebar tablet/desktop: 1200x800
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());

    final cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(4));

    // Di layar 1200px (2 kolom), tiap card lebarnya sekitar (1200 - padding - spasi)/2 = ~570px
    final width = tester.getSize(cardFinder.first).width;
    expect(width, greaterThan(450));
    expect(width, lessThan(700));
  });

  testWidgets('Toggle tema berpindah antara Light dan Dark mode', (tester) async {
    await tester.pumpWidget(const AcademicOverviewApp());

    // Awalnya mode terang (ikon light_mode aktif)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Tap CupertinoSwitch untuk beralih ke dark mode
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    // Sekarang menjadi dark mode (ikon dark_mode aktif)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}
