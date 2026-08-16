import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/flashcard.dart';
import '../../core/providers/service_providers.dart';
import '../cards/card_dialog.dart';
import '../cards/manage_view.dart';
import '../settings/settings_notifier.dart';
import '../settings/settings_view.dart';
import 'learning_controller.dart';
import 'learning_notifier.dart';
import 'widgets/rating_button.dart';
import 'widgets/stat_bar.dart';

class LearningView extends ConsumerStatefulWidget {
  const LearningView({super.key});

  @override
  ConsumerState<LearningView> createState() => _LearningViewState();
}

class _LearningViewState extends ConsumerState<LearningView> {
  bool _showBack = false;

  void _readAloudIfNeeded(Flashcard card, Map<String, dynamic> settings) async {
    final frontFirst = settings['frontFirst'] as bool;
    final readFront = settings['readFront'] as bool;
    final readBack = settings['readBack'] as bool;
    final langFront = settings['langFront'] as String;
    final langBack = settings['langBack'] as String;
    final speechRate = settings['speechRate'] as double;

    final tts = ref.read(ttsServiceProvider);

    if (readBack) {
      await tts.speak(frontFirst ? card.front : card.back, frontFirst ? langFront : langBack, speechRate);
    }
    if (readFront) {
      await tts.speak(frontFirst ? card.back : card.front, frontFirst ? langBack : langFront, speechRate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningNotifierProvider);
    final settingsAsync = ref.watch(settingsProvider);

    if (learningState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return settingsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (settings) {
        final cards = learningState.sessionCards;
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
              onPressed: () => ref.read(learningNotifierProvider.notifier).fetchNewCards(),
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
      Expanded(child: StatBar(label: 'Difficulty', value: currentCard.difficulty, color: Colors.orange)),
      const SizedBox(width: 12),
      Expanded(child: StatBar(label: 'Stability', value: currentCard.stability, color: Colors.blue)),
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
                  onPressed: () => ref.read(ttsServiceProvider).speak(text, currentLang, speechRate),
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
                  RatingButton(
                      label: 'Again',
                      color: Colors.red,
                      onPressed: () => _answer(currentCard, Rating.again)),
                  RatingButton(
                      label: 'Hard',
                      color: Colors.orange,
                      onPressed: () => _answer(currentCard, Rating.hard)),
                  RatingButton(
                      label: 'Good',
                      color: Colors.green,
                      onPressed: () => _answer(currentCard, Rating.good)),
                  RatingButton(
                      label: 'Easy',
                      color: Colors.blue,
                      onPressed: () => _answer(currentCard, Rating.easy)),
                ],
              )
            : null,
      ),
    );
  }

  void _answer(Flashcard card, Rating rating) {
    ref.read(learningNotifierProvider.notifier).answer(card, rating);
    setState(() => _showBack = false);
  }

  Widget _buildMenuButton(BuildContext context, Flashcard? currentCard) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'refresh') {
          ref.read(learningNotifierProvider.notifier).refresh();
          setState(() => _showBack = false);
        }
        if (value == 'add') showCardDialog(context);
        if (value == 'edit' && currentCard != null) showCardDialog(context, card: currentCard);
        if (value == 'delete' && currentCard != null) {
          _showBack = false;
          showDeleteConfirmation(context, ref, currentCard);
        }
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
