import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';

class SubscriptionState {
  final bool isPremium;
  final int sizingTriesUsed;
  final int capsuleTriesUsed;
  final int travelPackingTriesUsed;
  final int eventStylistTriesUsed;
  final String? premiumPlan;
  final DateTime? premiumSince;
  final bool isLoading;

  static const int maxFreeTries = 3;

  const SubscriptionState({
    this.isPremium = false,
    this.sizingTriesUsed = 0,
    this.capsuleTriesUsed = 0,
    this.travelPackingTriesUsed = 0,
    this.eventStylistTriesUsed = 0,
    this.premiumPlan,
    this.premiumSince,
    this.isLoading = false,
  });

  // --- Sizing Feature Tries ---
  int get remainingSizingTries {
    if (isPremium) return 999999;
    final rem = maxFreeTries - sizingTriesUsed;
    return rem < 0 ? 0 : rem;
  }
  bool get canUseSizing => isPremium || (sizingTriesUsed < maxFreeTries);

  // --- 10x30 Capsule Wardrobe Tries ---
  int get remainingCapsuleTries {
    if (isPremium) return 999999;
    final rem = maxFreeTries - capsuleTriesUsed;
    return rem < 0 ? 0 : rem;
  }
  bool get canUseCapsule => isPremium || (capsuleTriesUsed < maxFreeTries);

  // --- AI Travel Packing Tries ---
  int get remainingTravelPackingTries {
    if (isPremium) return 999999;
    final rem = maxFreeTries - travelPackingTriesUsed;
    return rem < 0 ? 0 : rem;
  }
  bool get canUseTravelPacking => isPremium || (travelPackingTriesUsed < maxFreeTries);

  // --- Event Stylist Tries ---
  int get remainingEventStylistTries {
    if (isPremium) return 999999;
    final rem = maxFreeTries - eventStylistTriesUsed;
    return rem < 0 ? 0 : rem;
  }
  bool get canUseEventStylist => isPremium || (eventStylistTriesUsed < maxFreeTries);

  SubscriptionState copyWith({
    bool? isPremium,
    int? sizingTriesUsed,
    int? capsuleTriesUsed,
    int? travelPackingTriesUsed,
    int? eventStylistTriesUsed,
    String? premiumPlan,
    DateTime? premiumSince,
    bool? isLoading,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      sizingTriesUsed: sizingTriesUsed ?? this.sizingTriesUsed,
      capsuleTriesUsed: capsuleTriesUsed ?? this.capsuleTriesUsed,
      travelPackingTriesUsed: travelPackingTriesUsed ?? this.travelPackingTriesUsed,
      eventStylistTriesUsed: eventStylistTriesUsed ?? this.eventStylistTriesUsed,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumSince: premiumSince ?? this.premiumSince,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    _init();
    return const SubscriptionState(isLoading: true);
  }

  Future<void> _init() async {
    // 1. Load from local cache first for instant UI response
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedIsPremium = prefs.getBool('cached_is_premium') ?? false;
      final cachedSizing = prefs.getInt('cached_sizing_tries') ?? 0;
      final cachedCapsule = prefs.getInt('cached_capsule_tries') ?? 0;
      final cachedTravel = prefs.getInt('cached_travel_tries') ?? 0;
      final cachedEvent = prefs.getInt('cached_event_tries') ?? 0;
      final cachedPlan = prefs.getString('cached_premium_plan');

      state = state.copyWith(
        isPremium: cachedIsPremium,
        sizingTriesUsed: cachedSizing,
        capsuleTriesUsed: cachedCapsule,
        travelPackingTriesUsed: cachedTravel,
        eventStylistTriesUsed: cachedEvent,
        premiumPlan: cachedPlan,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }

    // 2. Synchronize with Firestore real-time updates
    ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        _listenToUserDoc(user.uid);
      }
    }, fireImmediately: true);
  }

  void _listenToUserDoc(String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final isPrem = (data['isPremium'] as bool?) ?? false;
        final sizingTries = (data['sizingTriesUsed'] as num?)?.toInt() ?? 0;
        final capsuleTries = (data['capsuleTriesUsed'] as num?)?.toInt() ?? 0;
        final travelTries = (data['travelPackingTriesUsed'] as num?)?.toInt() ?? 0;
        final eventTries = (data['eventStylistTriesUsed'] as num?)?.toInt() ?? 0;
        final plan = data['premiumPlan'] as String?;
        final sinceRaw = data['premiumSince'];
        DateTime? since;
        if (sinceRaw is Timestamp) {
          since = sinceRaw.toDate();
        }

        state = state.copyWith(
          isPremium: isPrem,
          sizingTriesUsed: sizingTries,
          capsuleTriesUsed: capsuleTries,
          travelPackingTriesUsed: travelTries,
          eventStylistTriesUsed: eventTries,
          premiumPlan: plan,
          premiumSince: since,
          isLoading: false,
        );

        // Update local cache
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('cached_is_premium', isPrem);
          await prefs.setInt('cached_sizing_tries', sizingTries);
          await prefs.setInt('cached_capsule_tries', capsuleTries);
          await prefs.setInt('cached_travel_tries', travelTries);
          await prefs.setInt('cached_event_tries', eventTries);
          if (plan != null) {
            await prefs.setString('cached_premium_plan', plan);
          }
        } catch (_) {}
      }
    });
  }

  /// Increments free demo tries for Body Sizing
  Future<void> incrementSizingTries() async {
    if (state.isPremium) return;
    final newTries = state.sizingTriesUsed + 1;
    state = state.copyWith(sizingTriesUsed: newTries);
    await _persistTries('cached_sizing_tries', 'sizingTriesUsed', newTries);
  }

  /// Increments free demo tries for 10x30 Capsule Wardrobe
  Future<void> incrementCapsuleTries() async {
    if (state.isPremium) return;
    final newTries = state.capsuleTriesUsed + 1;
    state = state.copyWith(capsuleTriesUsed: newTries);
    await _persistTries('cached_capsule_tries', 'capsuleTriesUsed', newTries);
  }

  /// Increments free demo tries for AI Travel Packing
  Future<void> incrementTravelPackingTries() async {
    if (state.isPremium) return;
    final newTries = state.travelPackingTriesUsed + 1;
    state = state.copyWith(travelPackingTriesUsed: newTries);
    await _persistTries('cached_travel_tries', 'travelPackingTriesUsed', newTries);
  }

  /// Increments free demo tries for Event Stylist
  Future<void> incrementEventStylistTries() async {
    if (state.isPremium) return;
    final newTries = state.eventStylistTriesUsed + 1;
    state = state.copyWith(eventStylistTriesUsed: newTries);
    await _persistTries('cached_event_tries', 'eventStylistTriesUsed', newTries);
  }

  Future<void> _persistTries(String cacheKey, String firestoreKey, int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(cacheKey, count);
    } catch (_) {}

    final user = ref.read(authStateChangesProvider).value;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          firestoreKey: FieldValue.increment(1),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// Upgrades the user to FitLens Premium
  Future<bool> upgradeToPremium({String plan = 'annual'}) async {
    state = state.copyWith(isLoading: true);
    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      final now = DateTime.now();
      state = state.copyWith(
        isPremium: true,
        premiumPlan: plan,
        premiumSince: now,
        isLoading: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cached_is_premium', true);
      await prefs.setString('cached_premium_plan', plan);

      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'isPremium': true,
          'premiumPlan': plan,
          'premiumSince': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// Restores previous subscription purchases
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final isPrem = (doc.data()!['isPremium'] as bool?) ?? false;
          final plan = doc.data()!['premiumPlan'] as String?;
          state = state.copyWith(
            isPremium: isPrem,
            premiumPlan: plan,
            isLoading: false,
          );
          return isPrem;
        }
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// Cancels the current VIP subscription
  Future<bool> cancelSubscription() async {
    state = state.copyWith(isLoading: true);
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      state = state.copyWith(
        isPremium: false,
        premiumPlan: null,
        premiumSince: null,
        isLoading: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cached_is_premium', false);
      await prefs.remove('cached_premium_plan');

      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'isPremium': false,
          'cancelledAt': FieldValue.serverTimestamp(),
          'premiumPlan': null,
        }, SetOptions(merge: true));
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(SubscriptionNotifier.new);
