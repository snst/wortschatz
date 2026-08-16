import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/flashcard.dart';
import '../../core/providers/service_providers.dart';

class ImportView extends ConsumerStatefulWidget {
  const ImportView({super.key});

  @override
  ConsumerState<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends ConsumerState<ImportView> {
  final TextEditingController _controller = TextEditingController();
  bool _isImporting = false;

  Future<void> _importCards() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final List<dynamic> jsonList = jsonDecode(_controller.text);
      final List<Flashcard> cardsToImport = [];

      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          final String front = item['front']?.toString() ?? '';
          final String back = item['back']?.toString() ?? '';
          final String note = item['note']?.toString() ?? '';

          if (front.isNotEmpty && back.isNotEmpty) {
            cardsToImport.add(Flashcard(front: front, back: back, note: note));
          }
        }
      }

      if (cardsToImport.isNotEmpty) {
        await ref.read(databaseServiceProvider).addCards(cardsToImport);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Successfully imported ${cardsToImport.length} cards')));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid cards found in JSON')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error parsing JSON: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Cards')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(
                          text: '''
Du bist Spanischlehrer für lateinamerikanisches Spanisch.
Erstelle 20 Vokabelkarten zum Thema:
<thema>

</thema>

Anforderungen: 
- Verwende ausschließlich gebräuchliches, einfaches, leicht verständliches Vokabular lateinamerikanisches Spanisch.
- Übersetze jede Vokabel korrekt ins Deutsche.
- Füge nur bei Bedarf einen kurzen Hinweis hinzu (z. B. regionale Besonderheiten oder Aussprache).
- Gib ausschließlich gültiges JSON zurück. 

Format: 
[ 
  {
    "front": "spanische Vokabel",
    "back": "deutsche Übersetzung",
    "note": "Optionaler Hinweis"
  } 
]
''',
                        ),
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Prompt copied to clipboard')));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Prompt'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isImporting ? null : _importCards,
                    icon: _isImporting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download),
                    label: const Text('Import Cards'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '[\n  {\n    "front": "front",\n    "back": "back",\n    "note": "note"\n  }\n]',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
