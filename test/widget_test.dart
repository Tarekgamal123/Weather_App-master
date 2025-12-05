import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/pages/home/home_screen.dart'; // Add this import

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(MyApp());
    
    // Verify the app builds successfully
    expect(find.byType(MyApp), findsOneWidget);
  });
  
  testWidgets('Search field exists on home screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    
    // Should find search hint text (uppercase)
    expect(find.text('SEARCH'), findsOneWidget);
    
    // Should find search icon
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}