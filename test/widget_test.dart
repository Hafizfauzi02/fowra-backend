// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fowra/main.dart';

void main() {
  testWidgets('Calendar screen loads test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the header navigation arrows are displayed.
    expect(find.byIcon(Icons.arrow_circle_left_outlined), findsOneWidget);
    expect(find.byIcon(Icons.arrow_circle_right_outlined), findsOneWidget);

    // Verify the legend text is displayed
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('Not Submitted'), findsOneWidget);
  });
}
