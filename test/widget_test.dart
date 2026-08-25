import 'package:flutter_test/flutter_test.dart';

import 'package:app/app.dart';

void main() {
  testWidgets('ChargeLinkApp renders splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ChargeLinkApp());

    expect(find.text('ChargeLink'), findsOneWidget);
    expect(find.text('Powering Peer-to-Peer EV Charging'), findsOneWidget);
  });
}
