import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:specmoa_app/src/app.dart';

void main() {
  testWidgets('앱 기본 화면이 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(const SpecmoaApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
  });
}
