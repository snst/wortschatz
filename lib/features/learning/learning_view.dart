import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/flashcard.dart';
import '../cards/card_dialog.dart';
import '../cards/manage_view.dart';
import '../cards/statistics_view.dart';
import '../../core/providers/service_providers.dart';
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
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final learning = ref.watch(learningNotifierProvider);

    if (learning.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentCard = learning.currentCard;
    if (currentCard == null) {
      return _buildEmptyState(context);
    }

    return Scaffold(
      appBar: AppBar(
        leading: Center(
            child: Text('${learning.sessionCards.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.indigo))),
        title: _buildAppBarStats(currentCard),
        actions: [_buildMenuButton(context, currentCard)],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => _showAnswer = !_showAnswer);
          if (_showAnswer) {
            ref.read(learningNotifierProvider.notifier).speakSolutionIfNeeded();
          }
        },
        onLongPress: () {
          ref
              .read(learningNotifierProvider.notifier)
              .speakCurrentCard(!_showAnswer, true);
        },
        child: Column(
          children: [
            Expanded(
                child: _buildCardSide(learning, true)),
            const Divider(thickness: 1, indent: 48, endIndent: 48),
            Expanded(
                child: (!_showAnswer)
                    ? Center(
                        child: Text('(Tap to flip)',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16)))
                    : _buildCardSide(learning, false)),
            _buildBottomButtons(currentCard),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Center(
            child: Text('0',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey))),
        actions: [_buildMenuButton(context, null)],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text('No more cards!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(learningNotifierProvider.notifier).fetchNewCards(),
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
      Expanded(
          child: StatBar(
              label: 'Difficulty',
              value: currentCard.difficulty,
              color: Colors.orange)),
      const SizedBox(width: 12),
      Expanded(
          child: StatBar(
              label: 'Stability',
              value: currentCard.stability,
              color: Colors.blue)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Prio: ${currentCard.priority}',
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        Text("Rev: ${currentCard.reviewCount}",
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                fontWeight: FontWeight.bold))
      ]),
    ]);
  }

  Widget _buildCardSide(LearningState learning, bool isQuestion) {
    final text = isQuestion ? learning.displayQuestion : learning.displayAnswer;
    final note = isQuestion ? learning.displayNote : "";

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
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isQuestion ? null : Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref
                      .read(learningNotifierProvider.notifier)
                      .speakCurrentCard(isQuestion, false),
                  onLongPress: () => ref
                      .read(learningNotifierProvider.notifier)
                      .speakCurrentCard(isQuestion, true),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.volume_up,
                        color: isQuestion ? Colors.indigo : Colors.green),
                  ),
                ),
              ],
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(note,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.grey),
                  textAlign: TextAlign.center),
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
        child: _showAnswer
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
    setState(() => _showAnswer = false);
  }

  Widget _buildMenuButton(BuildContext context, Flashcard? currentCard) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'refresh') {
          ref.read(learningNotifierProvider.notifier).refresh();
          setState(() => _showAnswer = false);
        }
        if (value == 'add') showCardDialog(context);
        if (value == 'edit' && currentCard != null) {
          showCardDialog(context, card: currentCard);
        }
        if (value == 'delete' && currentCard != null) {
          _showAnswer = false;
          showDeleteConfirmation(context, ref, currentCard);
        }
        if (value == 'manage') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ManageView()));
        }
        if (value == 'statistics') {
          final allCards = await ref.read(databaseServiceProvider).getAllCards();
          if (context.mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StatisticsView(cards: allCards)));
          }
        }
        if (value == 'settings') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SettingsView()));
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 'manage',
            child: ListTile(
                leading: Icon(Icons.list_alt), title: Text('Manage Cards'))),
        const PopupMenuItem(
            value: 'statistics',
            child: ListTile(
                leading: Icon(Icons.bar_chart), title: Text('Statistics'))),
        const PopupMenuItem(
            value: 'refresh',
            child: ListTile(
                leading: Icon(Icons.refresh), title: Text('Refresh Batch'))),
        const PopupMenuItem(
            value: 'add',
            child: ListTile(leading: Icon(Icons.add), title: Text('Add Card'))),
        if (currentCard != null) ...[
          const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                  leading: Icon(Icons.edit), title: Text('Edit Card'))),
          const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                  leading: Icon(Icons.delete), title: Text('Delete Card'))),
        ],
        const PopupMenuItem(
            value: 'settings',
            child: ListTile(
                leading: Icon(Icons.settings), title: Text('Settings'))),
      ],
    );
  }
}
