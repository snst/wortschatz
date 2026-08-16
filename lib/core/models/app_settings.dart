import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const String keyFrontIsQuestion = 'front_is_question';
  static const String keyReadAnswer = 'read_answer';
  static const String keyLangFront = 'language_front';
  static const String keyLangBack = 'language_back';
  static const String keySpeechRate = 'speech_rate';
  static const String keySpeechRateSlow = 'speech_rate_slow';

  final bool frontIsQuestion;
  final bool readAnswer;
  final String langFront;
  final String langBack;
  final double speechRate;
  final double speechRateSlow;

  const AppSettings({
    required this.frontIsQuestion,
    required this.readAnswer,
    required this.langFront,
    required this.langBack,
    required this.speechRate,
    required this.speechRateSlow,
  });

  factory AppSettings.fromPrefs(SharedPreferences prefs) {
    return AppSettings(
      frontIsQuestion: prefs.getBool(keyFrontIsQuestion) ?? true,
      readAnswer: prefs.getBool(keyReadAnswer) ?? true,
      langFront: prefs.getString(keyLangFront) ?? "es-ES",
      langBack: prefs.getString(keyLangBack) ?? "de-DE",
      speechRate: prefs.getDouble(keySpeechRate) ?? 0.5,
      speechRateSlow: prefs.getDouble(keySpeechRateSlow) ?? 0.4,
    );
  }

  AppSettings copyWith({
    bool? frontIsQuestion,
    bool? readAnswer,
    String? langFront,
    String? langBack,
    double? speechRate,
    double? speechRateSlow,
  }) {
    return AppSettings(
      frontIsQuestion: frontIsQuestion ?? this.frontIsQuestion,
      readAnswer: readAnswer ?? this.readAnswer,
      langFront: langFront ?? this.langFront,
      langBack: langBack ?? this.langBack,
      speechRate: speechRate ?? this.speechRate,
      speechRateSlow: speechRateSlow ?? this.speechRateSlow,
    );
  }

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setBool(keyFrontIsQuestion, frontIsQuestion);
    await prefs.setBool(keyReadAnswer, readAnswer);
    await prefs.setString(keyLangFront, langFront);
    await prefs.setString(keyLangBack, langBack);
    await prefs.setDouble(keySpeechRate, speechRate);
    await prefs.setDouble(keySpeechRateSlow, speechRateSlow);
  }
}
