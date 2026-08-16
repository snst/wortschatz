import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'card_dialog.dart';
import 'database_service.dart';
import 'flashcard.dart';
import 'import_view.dart';
import 'providers.dart';

enum SortAttribute {
  id,
  priority,
  reviewCount,
  stability,
  difficulty,
  nextReview,
  lastReview,
}

class ManageView extends ConsumerStatefulWidget {
  const ManageView({super.key});

  @override
  ConsumerState<ManageView> createState() => _ManageViewState();
}

class _ManageViewState extends ConsumerState<ManageView> {
  SortAttribute _sortAttribute = SortAttribute.priority;
  bool _ascending = false;
  final TextEditingController _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _importFromFile(DatabaseService db) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      try {
        final String content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);

        if (!mounted) return;

        final options = await _showImportOptionsDialog();
        if (options == null) return;

        final importPriority = options['priority'] ?? true;
        final importLearning = options['learning'] ?? true;
        final useExistingIds = options['keepIds'] ?? false;

        final List<Flashcard> cardsToImport = [];

        for (var item in jsonList) {
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
          await db.addCards(cardsToImport, useExistingIds: useExistingIds);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully imported ${cardsToImport.length} cards')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error parsing JSON: $e')));
        }
      }
    }
  }

  Future<Map<String, bool>?> _showImportOptionsDialog() async {
    bool importPriority = true;
    bool importLearning = true;
    bool keepIds = false;

    return showDialog<Map<String, bool>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Import Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select which data to import besides Front, Back and Note:'),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Learning Progress'),
                subtitle: const Text('Stability, Difficulty, Review Dates, etc.'),
                value: importLearning,
                onChanged: (val) => setState(() => importLearning = val!),
              ),
              CheckboxListTile(
                title: const Text('Priority / Selection'),
                value: importPriority,
                onChanged: (val) => setState(() => importPriority = val!),
              ),
              CheckboxListTile(
                title: const Text('Keep IDs'),
                subtitle: const Text('Assign original IDs (may overwrite existing cards)'),
                value: keepIds,
                onChanged: (val) => setState(() => keepIds = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, {
                'priority': importPriority,
                'learning': importLearning,
                'keepIds': keepIds,
              }),
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToFile(DatabaseService db) async {
    try {
      final cards = await db.allCards.first;
      final List<Map<String, dynamic>> jsonList = cards
          .map((card) => {
                'id': card.id,
                'front': card.front,
                'back': card.back,
                'note': card.note,
                'nextReview': card.nextReview.toIso8601String(),
                'lastReview': card.lastReview.toIso8601String(),
                'priority': card.priority,
                'stability': card.stability,
                'difficulty': card.difficulty,
                'reviewCount': card.reviewCount,
              })
          .toList();
      final String content = const JsonEncoder.withIndent('  ').convert(jsonList);
      final String timestamp = DateFormat('ddMMyyyy_HHmm').format(DateTime.now());
      final String fileName = 'ws_$timestamp.json';

      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select where to save the cards:',
        fileName: fileName,
      );

      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsString(content);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully exported to ${outputPath.split('/').last}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseServiceProvider);
    final allCardsStream = db.allCards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cards'),
        actions: [
          IconButton(
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () => setState(() => _ascending = !_ascending),
            tooltip: 'Toggle Sort Order',
          ),
          PopupMenuButton<SortAttribute>(
            icon: const Icon(Icons.sort),
            onSelected: (attribute) => setState(() => _sortAttribute = attribute),
            itemBuilder: (context) => [
              const PopupMenuItem(value: SortAttribute.id, child: Text('Sort by ID')),
              const PopupMenuItem(value: SortAttribute.priority, child: Text('Sort by Priority')),
              const PopupMenuItem(value: SortAttribute.reviewCount, child: Text('Sort by Review Count')),
              const PopupMenuItem(value: SortAttribute.stability, child: Text('Sort by Stability')),
              const PopupMenuItem(value: SortAttribute.difficulty, child: Text('Sort by Difficulty')),
              const PopupMenuItem(value: SortAttribute.nextReview, child: Text('Sort by Next Review')),
              const PopupMenuItem(value: SortAttribute.lastReview, child: Text('Sort by Last Review')),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import_json') Navigator.push(context, MaterialPageRoute(builder: (context) => const ImportView()));
              else if (value == 'import_file') _importFromFile(db);
              else if (value == 'export_file') _exportToFile(db);
              else if (value == 'reset_progress') _showConfirmation(context, 'Reset Progress?', 'Really reset progress of all cards?', () => db.resetLearningProgress(), Colors.red);
              else if (value == 'delete_database') _showConfirmation(context, 'Delete Database?', 'Really delete all cards?', () => db.deleteAllCards(), Colors.red);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'import_json', child: ListTile(leading: Icon(Icons.download), title: Text('Import JSON'))),
              const PopupMenuItem(value: 'import_file', child: ListTile(leading: Icon(Icons.file_open), title: Text('Import File'))),
              const PopupMenuItem(value: 'export_file', child: ListTile(leading: Icon(Icons.upload), title: Text('Export File'))),
              const PopupMenuItem(value: 'reset_progress', child: ListTile(leading: Icon(Icons.restart_alt), title: Text('Reset Progress'))),
              const PopupMenuItem(value: 'delete_database', child: ListTile(leading: Icon(Icons.delete_forever), title: Text('Delete Database'))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => showCardDialog(context, db), child: const Icon(Icons.add)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filterController,
              decoration: InputDecoration(
                hintText: 'Search cards...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () { _filterController.clear(); setState(() {}); }),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Flashcard>>(
              stream: allCardsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final allCards = snapshot.data!;
                final query = _filterController.text.toLowerCase();
                final cards = query.length >= 2 ? allCards.where((c) => c.front.toLowerCase().contains(query) || c.back.toLowerCase().contains(query) || c.note.toLowerCase().contains(query)).toList() : allCards;

                cards.sort((a, b) {
                  int cmp = switch (_sortAttribute) {
                    SortAttribute.id => a.id.compareTo(b.id),
                    SortAttribute.priority => a.priority.compareTo(b.priority),
                    SortAttribute.reviewCount => a.reviewCount.compareTo(b.reviewCount),
                    SortAttribute.stability => a.stability.compareTo(b.stability),
                    SortAttribute.difficulty => a.difficulty.compareTo(b.difficulty),
                    SortAttribute.nextReview => a.nextReview.compareTo(b.nextReview),
                    SortAttribute.lastReview => a.lastReview.compareTo(b.lastReview),
                  };
                  return _ascending ? cmp : -cmp;
                });

                return ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return ListTile(
                      title: Text(card.front),
                      subtitle: Text(card.back),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${card.id}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          Checkbox(value: card.priority > 0, onChanged: (val) => db.updateCardSelectForLearning(card.id, val!)),
                        ],
                      ),
                      onTap: () => showCardDialog(context, db, card: card),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmation(BuildContext context, String title, String content, Future<void> Function() onConfirm, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () async { await onConfirm(); if (mounted) Navigator.pop(context); }, child: Text('Confirm', style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
