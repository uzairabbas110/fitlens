import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool dailyOutfitReminders;
  final bool promotionalOffers;

  const SettingsState({
    this.dailyOutfitReminders = true,
    this.promotionalOffers = false,
  });

  SettingsState copyWith({
    bool? dailyOutfitReminders,
    bool? promotionalOffers,
  }) {
    return SettingsState(
      dailyOutfitReminders: dailyOutfitReminders ?? this.dailyOutfitReminders,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState(); // Initial sync value
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      dailyOutfitReminders: prefs.getBool('dailyOutfitReminders') ?? true,
      promotionalOffers: prefs.getBool('promotionalOffers') ?? false,
    );
  }

  Future<void> toggleDailyOutfitReminders(bool value) async {
    state = state.copyWith(dailyOutfitReminders: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyOutfitReminders', value);
  }

  Future<void> togglePromotionalOffers(bool value) async {
    state = state.copyWith(promotionalOffers: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promotionalOffers', value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
