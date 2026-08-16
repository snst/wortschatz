import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/flashcard.dart';

enum SortAttribute {
  id,
  priority,
  reviewCount,
  stability,
  difficulty,
  nextReview,
  lastReview,
}

class ManageCardsState {
  final SortAttribute sortAttribute;
  final bool ascending;
  final String query;

  ManageCardsState({
    this.sortAttribute = SortAttribute.priority,
    this.ascending = false,
    this.query = '',
  });

  ManageCardsState copyWith({
    SortAttribute? sortAttribute,
    bool? ascending,
    String? query,
  }) {
    return ManageCardsState(
      sortAttribute: sortAttribute ?? this.sortAttribute,
      ascending: ascending ?? this.ascending,
      query: query ?? this.query,
    );
  }
}

class ManageCardsNotifier extends Notifier<ManageCardsState> {
  @override
  ManageCardsState build() => ManageCardsState();

  void setSortAttribute(SortAttribute attribute) {
    state = state.copyWith(sortAttribute: attribute);
  }

  void toggleAscending() {
    state = state.copyWith(ascending: !state.ascending);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  List<Flashcard> filterAndSort(List<Flashcard> cards) {
    final query = state.query.toLowerCase();
    var filtered = List<Flashcard>.from(query.length >= 2
        ? cards.where((c) =>
            c.front.toLowerCase().contains(query) ||
            c.back.toLowerCase().contains(query) ||
            c.note.toLowerCase().contains(query))
        : cards);

    filtered.sort((a, b) {
      int cmp = switch (state.sortAttribute) {
        SortAttribute.id => a.id.compareTo(b.id),
        SortAttribute.priority => a.priority.compareTo(b.priority),
        SortAttribute.reviewCount => a.reviewCount.compareTo(b.reviewCount),
        SortAttribute.stability => a.stability.compareTo(b.stability),
        SortAttribute.difficulty => a.difficulty.compareTo(b.difficulty),
        SortAttribute.nextReview => a.nextReview.compareTo(b.nextReview),
        SortAttribute.lastReview => a.lastReview.compareTo(b.lastReview),
      };
      return state.ascending ? cmp : -cmp;
    });

    return filtered;
  }
}

final manageCardsNotifierProvider = NotifierProvider<ManageCardsNotifier, ManageCardsState>(() {
  return ManageCardsNotifier();
});
