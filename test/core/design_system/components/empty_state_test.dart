import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tech_gadol_test_task/core/design_system/components/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders default message when no message provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(),
          ),
        ),
      );
      expect(find.text('No products found'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders custom message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(message: 'Select a product'),
          ),
        ),
      );
      expect(find.text('Select a product'), findsOneWidget);
    });

    testWidgets('shows clear button when onClearFilters is provided', (WidgetTester tester) async {
      var cleared = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No items',
              onClearFilters: () => cleared = true,
              clearFiltersLabel: 'Clear filters',
            ),
          ),
        ),
      );
      expect(find.text('Clear filters'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      await tester.pump();
      expect(cleared, isTrue);
    });

    testWidgets('does not show button when onClearFilters is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(message: 'Empty'),
          ),
        ),
      );
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });
}
