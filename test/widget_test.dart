import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:odoo_crm_mobile/app/app.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OdooCrmApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(OdooCrmApp), findsOneWidget);
  });
}
