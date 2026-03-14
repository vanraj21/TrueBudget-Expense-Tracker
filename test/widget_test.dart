import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:true_budget_app/screens/welcome_screen.dart';

void main() {
  testWidgets('Welcome screen renders correctly', (WidgetTester tester) async {
    // Build the welcome screen widget
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(),
      ),
    );
    
    // Wait for animations to complete
    await tester.pumpAndSettle();

    // Verify that the welcome screen elements are displayed
    expect(find.text('TrueBudget'), findsOneWidget);
    expect(find.text('Control Your Money Smartly'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
