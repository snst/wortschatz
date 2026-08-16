import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/import_export_service.dart';
import '../services/tts_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final importExportServiceProvider = Provider<ImportExportService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ImportExportService(db);
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});
