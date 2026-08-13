import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'card_dialog.dart';
import 'flashcard.dart';
import 'learning_controller.dart';
import 'manage_view.dart';
import 'providers.dart';
import 'settings_view.dart';

class LearningView extends ConsumerStatefulWidget {
  const LearningView({super.key});

  @override
  ConsumerState<LearningView> createState() => _LearningViewState();
}

class _LearningViewState extends ConsumerState<LearningView> {
  final FlutterTts _tts = FlutterTts();
  bool _showBack = false;

  // Funktion zum Vorlesen
  Future<void> _speak(String text, String language, double speechRate) async {
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(speechRate);
    await _tts.speak(text);
  }

  void _readAloudIfNeeded(Flashcard card, Map<String, dynamic> settings) async {
    final frontFirst = settings['frontFirst'] as bool;
    final readFront = settings['readFront'] as bool;
    final readBack = settings['readBack'] as bool;
    final langFront = settings['langFront'] as String;
    final langBack = settings['langBack'] as String;
    final speechRate = settings['speechRate'] as double;

    if (readBack) {
      await _speak(frontFirst ? card.front : card.back, frontFirst ? langFront : langBack, speechRate);
    }
    if (readFront) {
      await _speak(frontFirst ? card.back : card.front, frontFirst ? langBack : langFront, speechRate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(reviewableCardsProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return cardsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (cards) {
        return settingsAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
          data: (settings) {
            if (cards.isEmpty) {
              return _buildEmptyState(context);
            }

            final currentCard = cards.first;
            final frontFirst = settings['frontFirst'] as bool;
            final String displayFront = frontFirst ? currentCard.front : currentCard.back;
            final String displayBack = frontFirst ? currentCard.back : currentCard.front;

            return Scaffold(
              appBar: AppBar(
                leading: Center(
                    child: Text('${cards.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo))),
                title: _buildAppBarStats(currentCard),
                actions: [_buildMenuButton(context, currentCard)],
              ),
              body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() => _showBack = !_showBack);
                  if (_showBack) {
                    _readAloudIfNeeded(currentCard, settings);
                  }
                },
                child: Column(
                  children: [
                    Expanded(child: _buildCardSide(displayFront, currentCard.note, true, settings)),
                    const Divider(thickness: 1, indent: 48, endIndent: 48),
                    Expanded(child: _buildCardSide(displayBack, '', false, settings)),
                    _buildBottomButtons(currentCard),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Center(child: Text('0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey))),
        actions: [_buildMenuButton(context, null)],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text('No more cards!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(databaseServiceProvider).fetchNewCards(),
              icon: const Icon(Icons.refresh),
              label: const Text('Continue with new cards.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarStats(Flashcard currentCard) {
    return Row(children: [
      Expanded(child: _buildStatBar('Difficulty', currentCard.difficulty, Colors.orange)),
      const SizedBox(width: 12),
      Expanded(child: _buildStatBar('Stability', currentCard.stability, Colors.blue)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Prio: ${currentCard.priority}', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
        Text("Rev: ${currentCard.reviewCount}", style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold))
      ]),
    ]);
  }

  Widget _buildCardSide(String text, String note, bool isFront, Map<String, dynamic> settings) {
    if (!isFront && !_showBack) {
      return Center(child: Text('(Tap to flip)', style: TextStyle(color: Colors.grey[400], fontSize: 16)));
    }

    final langFront = settings['langFront'] as String;
    final langBack = settings['langBack'] as String;
    final frontFirst = settings['frontFirst'] as bool;
    final speechRate = settings['speechRate'] as double;
    final currentLang = isFront ? (frontFirst ? langFront : langBack) : (frontFirst ? langBack : langFront);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isFront ? null : Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up, color: isFront ? Colors.indigo : Colors.green),
                  onPressed: () => _speak(text, currentLang, speechRate),
                ),
              ],
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(note, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(Flashcard currentCard) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 100,
        child: _showBack
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRatedButton(currentCard, Rating.again, 'Again', Colors.red),
                  _buildRatedButton(currentCard, Rating.hard, 'Hard', Colors.orange),
                  _buildRatedButton(currentCard, Rating.good, 'Good', Colors.green),
                  _buildRatedButton(currentCard, Rating.easy, 'Easy', Colors.blue),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildStatBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
            Text(value.toStringAsFixed(2), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value.clamp(0, 10)) / 10.0,
            backgroundColor: color.withOpacity(0.2),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRatedButton(Flashcard card, Rating rating, String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: FilledButton(
          onPressed: () {
            ref.read(learningControllerProvider).answer(card, rating);
            ref.read(databaseServiceProvider).updateLearningProgress(card);
            setState(() => _showBack = false);
          },
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.zero,
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, Flashcard? currentCard) {
    final db = ref.read(databaseServiceProvider);
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'refresh') {
          await db.refreshReviewableCards();
          setState(() => _showBack = false);
        }
        if (value == 'add') showCardDialog(context, db);
        if (value == 'edit' && currentCard != null) showCardDialog(context, db, card: currentCard);
        if (value == 'delete' && currentCard != null) {             _showBack = false;
showDeleteConfirmation(context, db, currentCard);}
        if (value == 'manage') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageView()));
        }
        if (value == 'settings') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsView()));
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'manage', child: ListTile(leading: Icon(Icons.list_alt), title: Text('Manage Cards'))),
        const PopupMenuItem(value: 'refresh', child: ListTile(leading: Icon(Icons.refresh), title: Text('Refresh Batch'))),
        const PopupMenuItem(value: 'add', child: ListTile(leading: Icon(Icons.add), title: Text('Add Card'))),
        if (currentCard != null) ...[
          const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit Card'))),
          const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Delete Card'))),
        ],
        const PopupMenuItem(value: 'settings', child: ListTile(leading: Icon(Icons.settings), title: Text('Settings'))),
      ],
    );
  }
}
