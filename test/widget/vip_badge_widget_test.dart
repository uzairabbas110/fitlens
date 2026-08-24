import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VIP Badge & Greeting Widget Tests', () {
    Widget createGreetingWidget({required bool isPremium, required String userName}) {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Welcome back, $userName',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7E3B50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium, color: Colors.white, size: 12),
                            SizedBox(width: 3),
                            Text(
                              'VIP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isPremium
                      ? '✨ FitLens VIP • Unlimited AI Stylist Active'
                      : 'Ready to find your perfect look?',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('renders regular greeting without VIP badge for free user', (tester) async {
      await tester.pumpWidget(createGreetingWidget(isPremium: false, userName: 'Uzair'));

      expect(find.text('Welcome back, Uzair'), findsOneWidget);
      expect(find.text('Ready to find your perfect look?'), findsOneWidget);
      expect(find.text('VIP'), findsNothing);
      expect(find.byIcon(Icons.workspace_premium), findsNothing);
    });

    testWidgets('renders VIP badge and VIP subtitle for premium subscriber', (tester) async {
      await tester.pumpWidget(createGreetingWidget(isPremium: true, userName: 'Uzair'));

      expect(find.text('Welcome back, Uzair'), findsOneWidget);
      expect(find.text('VIP'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
      expect(find.text('✨ FitLens VIP • Unlimited AI Stylist Active'), findsOneWidget);
      expect(find.text('Ready to find your perfect look?'), findsNothing);
    });
  });
}
