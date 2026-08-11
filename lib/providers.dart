import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_service.dart';
import 'settings_service.dart';
import 'learning_controller.dart';
import 'flashcard.dart';

// Service Providers
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final learningControllerProvider = Provider<LearningController>((ref) {
  return LearningController();
});

// Settings Providers
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

// Learning Session Provider
final reviewableCardsProvider = StreamProvider<List<Flashcard>>((ref) {
  return ref.watch(databaseServiceProvider).reviewableCards;
});
