// This is a basic Flutter widget test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oppy2_frontend/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OppyAppWrapper());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
