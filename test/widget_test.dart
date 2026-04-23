import 'package:flutter_test/flutter_test.dart';

import 'package:noteshare/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NoteShareApp());
    expect(find.text('Study Together'), findsOneWidget);
  });
}
