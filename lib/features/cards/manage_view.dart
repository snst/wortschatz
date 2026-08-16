import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/flashcard.dart';
import '../../core/providers/service_providers.dart';
import '../import_export/import_view.dart';
import 'card_dialog.dart';
import 'manage_cards_notifier.dart';

class ManageView extends ConsumerStatefulWidget {
  const ManageView({super.key});

  @override
  ConsumerState<ManageView> createState() => _ManageViewState();
}

class _ManageViewState extends ConsumerState<ManageView> {
  final TextEditingController _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _importFromFile() async {
    final rawData = await ref.read(importExportServiceProvider).pickAndParseJson();
    if (rawData == null || rawData.isEmpty) return;

    if (!mounted) return;
    final options = await _showImportOptionsDialog(rawData.length);
    if (options == null) return;

    final count = await ref.read(importExportServiceProvider).importCards(
          rawData,
          importPriority: options['priority'] ?? true,
          importLearning: options['learning'] ?? true,
          useExistingIds: options['keepIds'] ?? false,
        );

    if (count > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully imported $count cards')));
    }
  }

  Future<Map<String, bool>?> _showImportOptionsDialog(int cardCount) async {
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
              Text('Found $cardCount cards in the file.'),
              const SizedBox(height: 8),
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

  Future<void> _exportToFile() async {
    final path = await ref.read(importExportServiceProvider).exportToFile();
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully exported to ${path.split('/').last}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseServiceProvider);
    final allCardsStream = db.allCards;
    final state = ref.watch(manageCardsNotifierProvider);
    final notifier = ref.read(manageCardsNotifierProvider.notifier);

    return StreamBuilder<List<Flashcard>>(
      stream: allCardsStream,
      builder: (context, snapshot) {
        final allCards = snapshot.data ?? [];
        final filteredCards = notifier.filterAndSort(allCards);

        return Scaffold(
          appBar: AppBar(
            title: Text('Manage Cards (${allCards.length})'),
            actions: [
              IconButton(
                icon: Icon(state.ascending ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: () => notifier.toggleAscending(),
                tooltip: 'Toggle Sort Order',
              ),
              PopupMenuButton<SortAttribute>(
                icon: const Icon(Icons.sort),
                onSelected: (attribute) => notifier.setSortAttribute(attribute),
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
                  if (value == 'import_json') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ImportView()));
                  } else if (value == 'import_file') {
                    _importFromFile();
                  } else if (value == 'export_file') {
                    _exportToFile();
                  } else if (value == 'reset_progress') {
                    _showConfirmation(context, 'Reset Progress?', 'Really reset progress of all cards?', () => db.resetLearningProgress(), Colors.red);
                  } else if (value == 'delete_database') {
                    _showConfirmation(context, 'Delete Database?', 'Really delete all cards?', () => db.deleteAllCards(), Colors.red);
                  }
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
          floatingActionButton: FloatingActionButton(onPressed: () => showCardDialog(context), child: const Icon(Icons.add)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _filterController,
                  decoration: InputDecoration(
                    hintText: 'Search cards...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () { _filterController.clear(); notifier.setQuery(''); }),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => notifier.setQuery(value),
                ),
              ),
              Expanded(
                child: snapshot.hasData
                    ? ListView.builder(
                        itemCount: filteredCards.length,
                        itemBuilder: (context, index) {
                          final card = filteredCards[index];
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
                            onTap: () => showCardDialog(context, card: card),
                          );
                        },
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        );
      },
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
          TextButton(onPressed: () async { await onConfirm(); if (context.mounted) Navigator.pop(context); }, child: Text('Confirm', style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
