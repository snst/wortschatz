import 'dart:async';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/flashcard.dart';

class DatabaseService {
  final AppDatabase _db = AppDatabase();

  Stream<List<Flashcard>> get allCards {
    return _db.select(_db.flashcardsTable).watch().map((rows) {
      return rows.map((row) => Flashcard.fromDrift(row)).toList();
    });
  }

  Stream<List<Flashcard>> get reviewableCards {
    return (_db.select(_db.flashcardsTable)
          ..where((t) => t.priority.isBiggerOrEqualValue(1))
          ..where((t) => t.nextReview.isSmallerOrEqualValue(DateTime.now()))
          ..orderBy([(t) => OrderingTerm(expression: t.nextReview)]))
        .watch()
        .map((rows) => rows.map((row) => Flashcard.fromDrift(row)).toList());
  }

  Stream<List<Flashcard>> get newCards {
    return (_db.select(_db.flashcardsTable)
          ..where((t) => t.priority.isBiggerOrEqualValue(1))
          ..orderBy([(t) => OrderingTerm(expression: t.stability)]))
        .watch()
        .map((rows) => rows.map((row) => Flashcard.fromDrift(row)).toList());
  }

  Future<void> addCard(String front, String back, String note, bool learnCard) async {
    await _db.into(_db.flashcardsTable).insert(FlashcardsTableCompanion.insert(
          front: front,
          back: back,
          note: Value(note),
          priority: Value(learnCard ? 1 : 0),
        ));
  }

  Future<void> addCards(List<Flashcard> cards, {bool useExistingIds = false}) async {
    await _db.batch((batch) {
      for (var card in cards) {
        batch.insert(
            _db.flashcardsTable,
            FlashcardsTableCompanion.insert(
              id: useExistingIds && card.id > 0 ? Value(card.id) : const Value.absent(),
              front: card.front,
              back: card.back,
              note: Value(card.note),
              priority: Value(card.priority),
              stability: Value(card.stability),
              difficulty: Value(card.difficulty),
              nextReview: Value(card.nextReview),
              lastReview: Value(card.lastReview),
              reviewCount: Value(card.reviewCount),
            ),
            mode: useExistingIds ? InsertMode.insertOrReplace : InsertMode.insert);
      }
    });
  }

  Future<void> updateCard(Flashcard card) async {
    await (_db.update(_db.flashcardsTable)..where((t) => t.id.equals(card.id))).write(
      FlashcardsTableCompanion(
        front: Value(card.front),
        back: Value(card.back),
        note: Value(card.note),
        priority: Value(card.priority),
        stability: Value(card.stability),
        difficulty: Value(card.difficulty),
        reviewCount: Value(card.reviewCount),
        lastReview: Value(card.lastReview),
        nextReview: Value(card.nextReview),
      ),
    );
  }

  Future<void> updateCardSelectForLearning(int id, bool learn) async {
    await (_db.update(_db.flashcardsTable)..where((t) => t.id.equals(id))).write(
      FlashcardsTableCompanion(priority: Value(learn ? 1 : 0)),
    );
  }

  Future<void> deleteCard(int id) async {
    await (_db.delete(_db.flashcardsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> resetLearningProgress() async {
    await (_db.update(_db.flashcardsTable)).write(
      const FlashcardsTableCompanion(
        stability: Value(1.0),
        difficulty: Value(5.0),
        reviewCount: Value(0),
      ),
    );
  }

  Future<void> deleteAllCards() async {
    await _db.delete(_db.flashcardsTable).go();
  }
}
