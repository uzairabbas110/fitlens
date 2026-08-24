import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sizing Trial Banner Widget Tests', () {
    Widget createTrialBannerWidget({required int remainingTries, required bool isPremium}) {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) {
                if (isPremium) {
                  return const Text('VIP Unlimited AI Sizing Active');
                }
                if (remainingTries > 0) {
                  return Text('✨ Free Demo Trial: $remainingTries of 3 tries remaining');
                } else {
                  return const Text('🔒 Free Demo Limit Reached (3/3 Used) • Tap to Upgrade');
                }
              },
            ),
          ),
        ),
      );
    }

    testWidgets('renders 3 of 3 tries remaining for new user', (tester) async {
      await tester.pumpWidget(createTrialBannerWidget(remainingTries: 3, isPremium: false));
      expect(find.text('✨ Free Demo Trial: 3 of 3 tries remaining'), findsOneWidget);
    });

    testWidgets('renders 1 of 3 tries remaining after 2 scans', (tester) async {
      await tester.pumpWidget(createTrialBannerWidget(remainingTries: 1, isPremium: false));
      expect(find.text('✨ Free Demo Trial: 1 of 3 tries remaining'), findsOneWidget);
    });

    testWidgets('renders Limit Reached banner when all 3 tries are consumed', (tester) async {
      await tester.pumpWidget(createTrialBannerWidget(remainingTries: 0, isPremium: false));
      expect(find.text('🔒 Free Demo Limit Reached (3/3 Used) • Tap to Upgrade'), findsOneWidget);
      expect(find.text('✨ Free Demo Trial: 0 of 3 tries remaining'), findsNothing);
    });

    testWidgets('renders VIP Unlimited banner for premium member', (tester) async {
      await tester.pumpWidget(createTrialBannerWidget(remainingTries: 0, isPremium: true));
      expect(find.text('VIP Unlimited AI Sizing Active'), findsOneWidget);
    });
  });
}
