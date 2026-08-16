import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import '../services/import_export_service.dart';
import '../services/tts_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final importExportServiceProvider = Provider<ImportExportService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ImportExportService(db);
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});
