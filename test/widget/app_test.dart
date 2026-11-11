import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/app/app.dart';

void main() {
  testWidgets('the app starts', (tester) async {
    await tester.pumpWidget(const LudoApp());
    expect(find.text('Ludo Unbiased'), findsOneWidget);
  });
}
