import 'database.dart';

class Flashcard {
  int id;
  String front;
  String back;
  String note;
  DateTime nextReview;
  DateTime lastReview;
  int priority;
  double stability;
  double difficulty;
  int reviewCount = 0;

  Flashcard({
    this.id = 0,
    required this.front,
    required this.back,
    this.note = '',
    DateTime? nextReview,
    DateTime? lastReview,
    this.priority = 1,
    this.stability = 1.0,
    this.difficulty = 5.0,
    this.reviewCount = 0,
  })  : nextReview = nextReview ?? DateTime.now(),
        lastReview = lastReview ?? DateTime.now();

  factory Flashcard.fromDrift(FlashcardsTableData data) {
    return Flashcard(
      id: data.id,
      front: data.front,
      back: data.back,
      note: data.note,
      nextReview: data.nextReview,
      lastReview: data.lastReview,
      priority: data.priority,
      stability: data.stability,
      difficulty: data.difficulty,
      reviewCount: data.reviewCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'front': front,
      'back': back,
      'note': note,
      'nextReview': nextReview,
      'lastReview': lastReview,
      'priority': priority,
      'stability': stability,
      'difficulty': difficulty,
      'reviewCount': reviewCount,
    };
  }
}
