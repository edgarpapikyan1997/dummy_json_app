import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tech_gadol_test_task/core/design_system/components/app_card.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders child when onTap is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: const Text('Card content'),
            ),
          ),
        ),
      );
      expect(find.text('Card content'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('renders with InkWell when onTap is provided', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Tappable'),
            ),
          ),
        ),
      );
      expect(find.text('Tappable'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('applies custom padding and margin when provided', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(24);
      const customMargin = EdgeInsets.symmetric(horizontal: 16);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              padding: customPadding,
              margin: customMargin,
              child: const Text('Content'),
            ),
          ),
        ),
      );
      final appCard = tester.widget<AppCard>(find.byType(AppCard));
      expect(appCard.padding, customPadding);
      expect(appCard.margin, customMargin);
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, customMargin);
    });
  });
}
