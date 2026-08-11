import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyDirection = 'learning_direction';
  static const String _languageFront = 'language_front';
  static const String _languageBack = 'language_back';
  static const String _readFront = 'read_front';
  static const String _readBack = 'read_back';
  static const String _speechRate = 'speech_rate';

  // direction: true = front first (default), false = back first
  Future<bool> getFrontFirst() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDirection) ?? true;
  }

  Future<void> setFrontFirst(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDirection, value);
  }

  Future<bool> getReadFront() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_readFront) ?? true;
  }

  Future<void> setReadFront(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_readFront, value);
  }

  Future<bool> getReadBack() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_readBack) ?? true;
  }

  Future<void> setReadBack(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_readBack, value);
  }

  Future<String> getLanguageBack() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageBack) ?? "de-DE";
  }

  Future<void> setLanguageBack(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageBack, value);
  }

  Future<String> getLanguageFront() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageFront) ?? "es-ES";
  }

  Future<void> setLanguageFront(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageFront, value);
  }

  Future<double> getSpeechRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_speechRate) ?? 0.5;
  }

  Future<void> setSpeechRate(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speechRate, value);
  }
}
