import 'dart:async';

import 'package:drift/drift.dart';

import 'database.dart';
import 'flashcard.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  final AppDatabase _db = AppDatabase();

  final List<Flashcard> _cardBuffer = [];
  final StreamController<List<Flashcard>> _reviewableCardsController = StreamController<List<Flashcard>>.broadcast();
  bool _isFetching = false;

  void _notifyBuffer() {
    if (!_reviewableCardsController.isClosed) {
      _reviewableCardsController.add(List.unmodifiable(_cardBuffer));
    }
  }

  Future<void> _fetchNextBatch() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final query = _db.select(_db.flashcardsTable)
        ..where((t) => t.priority.isBiggerOrEqualValue(1))
        ..where((t) => t.nextReview.isSmallerOrEqualValue(DateTime.now()))
        ..orderBy([(t) => OrderingTerm(expression: t.nextReview)])
        ..limit(20);

      final results = await query.get();
      List<Flashcard> fetchedCards = results.map((row) => Flashcard.fromDrift(row)).toList();

      fetchedCards.shuffle();
      _cardBuffer.clear();
      _cardBuffer.addAll(fetchedCards);

      _notifyBuffer();
    } catch (e, stackTrace) {
      print("Error fetching cards: $e");
      if (!_reviewableCardsController.isClosed) {
        _reviewableCardsController.addError(e, stackTrace);
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<void> fetchNewCards() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final query = _db.select(_db.flashcardsTable)
        ..where((t) => t.priority.isBiggerOrEqualValue(1))
        ..orderBy([(t) => OrderingTerm(expression: t.stability)])
        ..limit(20);

      final results = await query.get();
      List<Flashcard> fetchedCards = results.map((row) => Flashcard.fromDrift(row)).toList();
      fetchedCards.shuffle();

      _cardBuffer.clear();
      _cardBuffer.addAll(fetchedCards);

      _notifyBuffer();
    } catch (e, stackTrace) {
      print("Error fetching new cards: $e");
      if (!_reviewableCardsController.isClosed) {
        _reviewableCardsController.addError(e, stackTrace);
      }
    } finally {
      _isFetching = false;
    }
  }

  // Stream für alle Karten (wichtig für den Editiermodus)
  Stream<List<Flashcard>> get allCards {
    return _db.select(_db.flashcardsTable).watch().map((rows) {
      return rows.map((row) => Flashcard.fromDrift(row)).toList();
    });
  }

  // Stream für fällige Karten im Lernmodus
  Stream<List<Flashcard>> get reviewableCards {
    if (_cardBuffer.isEmpty) {
      _fetchNextBatch();
    } else {
      scheduleMicrotask(() {
        _notifyBuffer();
      });
    }
    return _reviewableCardsController.stream;
  }

  // Karte hinzufügen
  Future<void> addCard(String front, String back, String note, bool learnCard) async {
    await _db.into(_db.flashcardsTable).insert(FlashcardsTableCompanion.insert(
          front: front,
          back: back,
          note: Value(note),
          priority: Value(learnCard ? 1 : 0),
        ));
  }

  Future<void> addCards(List<Flashcard> cards) async {
    await _db.batch((batch) {
      for (var card in cards) {
        batch.insert(
            _db.flashcardsTable,
            FlashcardsTableCompanion.insert(
              front: card.front,
              back: card.back,
              note: Value(card.note),
              priority: Value(card.priority),
              stability: Value(card.stability),
              difficulty: Value(card.difficulty),
              nextReview: Value(card.nextReview),
              lastReview: Value(card.lastReview),
              reviewCount: Value(card.reviewCount),
            ));
      }
    });
    await _clearBufferAndFetch();
  }

  void _updateBufferItem(int id, bool Function(Flashcard card) updateAction) {
    final index = _cardBuffer.indexWhere((c) => c.id == id);
    if (index != -1) {
      if (!updateAction(_cardBuffer[index])) {
        _cardBuffer.removeAt(index);
      }
      _notifyBuffer();
    }
  }

  // Karte aktualisieren (Editier-Modus)
  Future<void> updateCard(int id, String front, String back, String note, bool learnCard) async {
    final priority = learnCard ? 1 : 0;
    await (_db.update(_db.flashcardsTable)..where((t) => t.id.equals(id))).write(
      FlashcardsTableCompanion(
        front: Value(front),
        back: Value(back),
        note: Value(note),
        priority: Value(priority),
      ),
    );

    _updateBufferItem(id, (card) {
      if (!learnCard) return false;
      card.front = front;
      card.back = back;
      card.note = note;
      card.priority = priority;
      return true;
    });
  }

  Future<void> updateCardSelectForLearning(int id, bool learn) async {
    int priority = learn ? 1 : 0;
    await (_db.update(_db.flashcardsTable)..where((t) => t.id.equals(id))).write(
      FlashcardsTableCompanion(priority: Value(priority)),
    );

    _updateBufferItem(id, (card) {
      card.priority = priority;
      return true;
    });
  }

  Future<void> updateCardResetProgress(int id) async {
    await (_db.update(_db.flashcardsTable)..where((t) => t.id.equals(id))).write(
      const FlashcardsTableCompanion(
        stability: Value(1.0),
        difficulty: Value(5.0),
      ),
    );

    _updateBufferItem(id, (card) {
      card.stability = 1.0;
      card.difficulty = 5.0;
      return true;
    });
  }

  // Karte löschen
  Future<void> deleteCard(int id) async {
    await (_db.delete(_db.flashcardsTable)..where((t) => t.id.equals(id))).go();
    _updateBufferItem(id, (card) => false);
  }

  // Leitner-Logik: Antwort war richtig oder falsch
  Future<void> updateLearningProgress(Flashcard card) async {
    await (_db.update(_db.flashcardsTable)..where((t) => t.id.equals(card.id))).write(
      FlashcardsTableCompanion(
        stability: Value(card.stability),
        difficulty: Value(card.difficulty),
        reviewCount: Value(card.reviewCount),
        lastReview: Value(card.lastReview),
        nextReview: Value(card.nextReview),
      ),
    );

    // Remove from buffer and notify
    _cardBuffer.removeWhere((c) => c.id == card.id);
    if (_cardBuffer.isEmpty) {
      _fetchNextBatch();
    } else {
      _notifyBuffer();
    }
  }

  Future<void> refreshReviewableCards() async {
    await _clearBufferAndFetch();
  }

  Future<void> _clearBufferAndFetch() async {
    _cardBuffer.clear();
    await _fetchNextBatch();
  }

  // Alle Karten sofort wieder fällig machen
  Future<void> resetReviewDates() async {
    await (_db.update(_db.flashcardsTable)).write(
      FlashcardsTableCompanion(nextReview: Value(DateTime.now())),
    );
    await _clearBufferAndFetch();
  }

  Future<void> resetLearningProgress() async {
    await (_db.update(_db.flashcardsTable)).write(
      const FlashcardsTableCompanion(
        stability: Value(1.0),
        difficulty: Value(5.0),
      ),
    );
    await _clearBufferAndFetch();
  }

  Future<void> deleteAllCards() async {
    await _db.delete(_db.flashcardsTable).go();
    await _clearBufferAndFetch();
  }
}
