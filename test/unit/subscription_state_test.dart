import 'package:flutter_test/flutter_test.dart';
import 'package:fitlens/core/providers/subscription_provider.dart';

void main() {
  group('SubscriptionState Unit Tests', () {
    test('initial state has default freemium values (0 tries used, 3 remaining)', () {
      const state = SubscriptionState();
      expect(state.isPremium, isFalse);
      expect(state.sizingTriesUsed, equals(0));
      expect(state.remainingSizingTries, equals(3));
      expect(state.canUseSizing, isTrue);
      expect(state.premiumPlan, isNull);
      expect(state.isLoading, isFalse);
    });

    test('remaining tries decrement accurately as tries are used', () {
      const state1 = SubscriptionState(sizingTriesUsed: 1);
      expect(state1.remainingSizingTries, equals(2));
      expect(state1.canUseSizing, isTrue);

      const state2 = SubscriptionState(sizingTriesUsed: 2);
      expect(state2.remainingSizingTries, equals(1));
      expect(state2.canUseSizing, isTrue);

      const state3 = SubscriptionState(sizingTriesUsed: 3);
      expect(state3.remainingSizingTries, equals(0));
      expect(state3.canUseSizing, isFalse);
    });

    test('remaining tries do not drop below zero when tries exceed limit', () {
      const state = SubscriptionState(sizingTriesUsed: 5);
      expect(state.remainingSizingTries, equals(0));
      expect(state.canUseSizing, isFalse);
    });

    test('VIP state grants unlimited access regardless of tries used', () {
      const state = SubscriptionState(isPremium: true, sizingTriesUsed: 10, premiumPlan: 'annual');
      expect(state.isPremium, isTrue);
      expect(state.canUseSizing, isTrue);
      expect(state.premiumPlan, equals('annual'));
    });

    test('copyWith properly updates selective fields without mutating others', () {
      const initial = SubscriptionState(sizingTriesUsed: 1, isPremium: false);
      final updated = initial.copyWith(isPremium: true, premiumPlan: 'monthly');
      
      expect(updated.isPremium, isTrue);
      expect(updated.premiumPlan, equals('monthly'));
      expect(updated.sizingTriesUsed, equals(1));
      expect(initial.isPremium, isFalse);
    });
  });
}
