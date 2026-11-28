import 'package:flutter_test/flutter_test.dart';
import 'package:lab12/main.dart';

void main() {
  testWidgets('Login screen test', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Қош келдіңіз!'), findsOneWidget);
    expect(find.text('Кіру'), findsOneWidget);
  });
}