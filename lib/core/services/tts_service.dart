import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, String language, double speechRate) async {
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(speechRate);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
