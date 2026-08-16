import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_settings.dart';
import '../../core/providers/service_providers.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings.fromPrefs(prefs);
  }

  void _update(AppSettings newSettings) {
    state = newSettings;
    state.save(ref.read(sharedPreferencesProvider));
  }

  set frontFirst(bool val) => _update(state.copyWith(frontIsQuestion: val));
  set readAnswer(bool val) => _update(state.copyWith(readAnswer: val));
  set langFront(String val) => _update(state.copyWith(langFront: val));
  set langBack(String val) => _update(state.copyWith(langBack: val));
  set speechRate(double val) => _update(state.copyWith(speechRate: val));
  set speechRateSlow(double val) => _update(state.copyWith(speechRateSlow: val));
}
