import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/flashcard.dart';
import '../../core/providers/service_providers.dart';
import 'learning_controller.dart';

class LearningState {
  final List<Flashcard> sessionCards;
  final bool isLoading;

  LearningState({
    this.sessionCards = const [],
    this.isLoading = false,
  });

  LearningState copyWith({
    List<Flashcard>? sessionCards,
    bool? isLoading,
  }) {
    return LearningState(
      sessionCards: sessionCards ?? this.sessionCards,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LearningNotifier extends Notifier<LearningState> {
  @override
  LearningState build() {
    _fetchNextBatch();
    return LearningState(isLoading: true);
  }

  Future<void> _fetchNextBatch() async {
    final db = ref.read(databaseServiceProvider);
    try {
      final all = await db.reviewableCards.first;
      final cards = all.take(20).toList()..shuffle();
      state = state.copyWith(sessionCards: cards, isLoading: false);
    } catch (e) {
      state = state.copyWith(sessionCards: [], isLoading: false);
    }
  }

  Future<void> fetchNewCards() async {
    state = state.copyWith(isLoading: true);
    final db = ref.read(databaseServiceProvider);
    try {
      final all = await db.newCards.first;
      final cards = all.take(20).toList()..shuffle();
      state = state.copyWith(sessionCards: cards, isLoading: false);
    } catch (e) {
      state = state.copyWith(sessionCards: [], isLoading: false);
    }
  }

  Future<void> answer(Flashcard card, Rating rating) async {
    final controller = ref.read(learningControllerProvider);
    final updatedCard = controller.answer(card, rating);
    
    await ref.read(databaseServiceProvider).updateCard(updatedCard);
    
    final newList = List<Flashcard>.from(state.sessionCards);
    newList.removeWhere((c) => c.id == card.id);
    
    if (newList.isEmpty) {
      state = state.copyWith(sessionCards: newList, isLoading: true);
      await _fetchNextBatch();
    } else {
      state = state.copyWith(sessionCards: newList);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _fetchNextBatch();
  }
}

final learningControllerProvider = Provider<LearningController>((ref) => LearningController());

final learningNotifierProvider = NotifierProvider<LearningNotifier, LearningState>(() {
  return LearningNotifier();
});
