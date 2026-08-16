import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Map<String, dynamic>>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final service = ref.watch(settingsServiceProvider);
    return {
      'frontFirst': await service.getFrontFirst(),
      'readFront': await service.getReadFront(),
      'readBack': await service.getReadBack(),
      'langFront': await service.getLanguageFront(),
      'langBack': await service.getLanguageBack(),
      'speechRate': await service.getSpeechRate(),
    };
  }

  Future<void> setFrontFirst(bool value) async {
    await ref.read(settingsServiceProvider).setFrontFirst(value);
    ref.invalidateSelf();
  }

  Future<void> setReadFront(bool value) async {
    await ref.read(settingsServiceProvider).setReadFront(value);
    ref.invalidateSelf();
  }

  Future<void> setReadBack(bool value) async {
    await ref.read(settingsServiceProvider).setReadBack(value);
    ref.invalidateSelf();
  }

  Future<void> setLanguageFront(String value) async {
    await ref.read(settingsServiceProvider).setLanguageFront(value);
    ref.invalidateSelf();
  }

  Future<void> setLanguageBack(String value) async {
    await ref.read(settingsServiceProvider).setLanguageBack(value);
    ref.invalidateSelf();
  }

  Future<void> setSpeechRate(double value) async {
    await ref.read(settingsServiceProvider).setSpeechRate(value);
    ref.invalidateSelf();
  }
}
