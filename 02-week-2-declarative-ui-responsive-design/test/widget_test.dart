import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we2/main.dart';

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());

    final width = tester.getSize(find.byType(Card).first).width;
    expect(width, lessThan(700));
  });

  testWidgets('Dashboard dua kolom di layar lebar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());

    final width = tester.getSize(find.byType(Card).first).width;
    expect(width, greaterThan(500));
  });
}
