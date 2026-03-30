import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tech_gadol_test_task/core/design_system/components/empty_state.dart';

void main() {
  testWidgets('App placeholder smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(message: 'Products'),
        ),
      ),
    );
    expect(find.text('Products'), findsOneWidget);
  });
}
