import 'package:flutter_test/flutter_test.dart';
import 'package:specmoa_app/src/app.dart';

void main() {
  testWidgets('로그인 화면이 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(const SpecmoaApp());
    await tester.pumpAndSettle();

    expect(find.text('다시 만나서 반가워요'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('회원가입'), findsOneWidget);
  });
}
