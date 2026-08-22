import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/flashcard.dart';
import '../../core/providers/service_providers.dart';
import '../settings/settings_notifier.dart';
import 'learning_controller.dart';

class LearningState {
  final List<Flashcard> sessionCards;
  final bool isLoading;
  final AppSettings settings;

  LearningState({
    required this.sessionCards,
    required this.isLoading,
    required this.settings,
  });

  Flashcard? get currentCard => sessionCards.isEmpty ? null : sessionCards.first;
  
  String get displayQuestion => currentCard == null ? '' : (settings.frontIsQuestion ? currentCard!.front : currentCard!.back);
  String get displayAnswer => currentCard == null ? '' : (settings.frontIsQuestion ? currentCard!.back : currentCard!.front);
  String get displayNote => currentCard == null ? '' : currentCard!.note;

  LearningState copyWith({
    List<Flashcard>? sessionCards,
    bool? isLoading,
    AppSettings? settings,
  }) {
    return LearningState(
      sessionCards: sessionCards ?? this.sessionCards,
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
    );
  }
}

class LearningNotifier extends Notifier<LearningState> {
  @override
  LearningState build() {
    final settings = ref.watch(settingsProvider);
    // Note: This build will run again if settings changes.
    // We only trigger fetch if cards are empty and not loading.
    
    // Use a microtask to avoid modifying state during build if needed, 
    // but here we are just initializing.
    
    // We need to keep the session cards across settings changes.
    // If the state was already initialized, we keep the cards.
    final currentCards = stateOrNull?.sessionCards ?? [];
    final wasLoading = stateOrNull?.isLoading ?? true;
    
    if (currentCards.isEmpty && wasLoading) {
      _fetchNextBatch();
    }

    return LearningState(
      sessionCards: currentCards,
      isLoading: currentCards.isEmpty && wasLoading,
      settings: settings,
    );
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

  Future<void> updatePriority(Flashcard card, int delta) async {
    final newPriority = (card.priority + delta).clamp(0, 99);
    if (newPriority == card.priority) return;

    final updatedCard = card.copyWith(priority: newPriority);
    await ref.read(databaseServiceProvider).updateCard(updatedCard);

    final newList = List<Flashcard>.from(state.sessionCards);
    if (newPriority == 0) {
      newList.removeWhere((c) => c.id == card.id);
      if (newList.isEmpty) {
        state = state.copyWith(sessionCards: newList, isLoading: true);
        await _fetchNextBatch();
      } else {
        state = state.copyWith(sessionCards: newList);
      }
    } else {
      final index = newList.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        newList[index] = updatedCard;
        state = state.copyWith(sessionCards: newList);
      }
    }
  }

  void speakCurrentCard(bool isQuestion, bool slow) {
    final card = state.currentCard;
    if (card == null) return;
    
    final tts = ref.read(ttsServiceProvider);
    
    final isFrontSide = state.settings.frontIsQuestion ? isQuestion : !isQuestion;
    final text = isFrontSide ? card.front : card.back;
    final lang = isFrontSide ? state.settings.langFront : state.settings.langBack;
    
    final rate = slow ? state.settings.speechRateSlow : state.settings.speechRate;
    tts.speak(text, lang, rate);
  }

  void speakSolutionIfNeeded() {
    if (state.settings.readAnswer) {
      speakCurrentCard(false, false);
    }
  }
}

final learningControllerProvider = Provider<LearningController>((ref) => LearningController());

final learningNotifierProvider = NotifierProvider<LearningNotifier, LearningState>(() {
  return LearningNotifier();
});
