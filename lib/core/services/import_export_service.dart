import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/flashcard.dart';
import 'database_service.dart';

class ImportExportService {
  final DatabaseService _db;

  ImportExportService(this._db);

  Future<List<dynamic>?> pickAndParseJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return null;

    try {
      final file = File(result.files.single.path!);
      final String content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return decoded;
      }
    } catch (e) {
      // Log or handle error
    }
    return null;
  }

  Future<int> importCards(
    List<dynamic> rawData, {
    required bool importPriority,
    required bool importLearning,
    required bool useExistingIds,
  }) async {
    final List<Flashcard> cardsToImport = [];

    for (var item in rawData) {
      if (item is Map<String, dynamic>) {
        Map<String, dynamic> filteredItem = Map.from(item);
        if (!importPriority) filteredItem.remove('priority');
        if (!importLearning) {
          filteredItem.remove('nextReview');
          filteredItem.remove('lastReview');
          filteredItem.remove('stability');
          filteredItem.remove('difficulty');
          filteredItem.remove('reviewCount');
        }
        if (!useExistingIds) filteredItem.remove('id');

        final card = Flashcard.fromJson(filteredItem);
        if (card.front.isNotEmpty && card.back.isNotEmpty) {
          cardsToImport.add(card);
        }
      }
    }

    if (cardsToImport.isNotEmpty) {
      await _db.addCards(cardsToImport, useExistingIds: useExistingIds);
    }
    return cardsToImport.length;
  }

  Future<String?> exportToFile() async {
    final cards = await _db.allCards.first;
    final List<Map<String, dynamic>> jsonList =
        cards.map((card) => card.toJson()).toList();

    final String content = const JsonEncoder.withIndent('  ').convert(jsonList);
    final Uint8List bytes = utf8.encode(content);
    final String timestamp = DateFormat('ddMMyyyy_HHmm').format(DateTime.now());
    final String fileName = 'ws_$timestamp.json';

    final String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select where to save the cards:',
      fileName: fileName,
      bytes: bytes,
    );

    if (outputPath != null) {
      // On Android & iOS, file_picker handles the writing via the 'bytes' parameter.
      // On Desktop (Linux, Windows, macOS), we must write the file manually to the returned path.
      if (!Platform.isAndroid && !Platform.isIOS) {
        final file = File(outputPath);
        await file.writeAsBytes(bytes);
      }
      return outputPath;
    }
    return null;
  }
}
