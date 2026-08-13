import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:traduttore_vocale/main.dart';

void main() {
  testWidgets('Home screen shows Italian and English fields', (WidgetTester tester) async {
    await tester.pumpWidget(const TraduttoreVocaleApp());

    expect(find.text('Italiano'), findsOneWidget);
    expect(find.text('Inglese'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Traduci'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Pronuncia in inglese'), findsOneWidget);
  });
}
