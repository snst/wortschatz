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

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] is int ? json['id'] : 0,
      front: json['front']?.toString() ?? '',
      back: json['back']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      nextReview: json['nextReview'] != null ? DateTime.tryParse(json['nextReview'].toString()) : null,
      lastReview: json['lastReview'] != null ? DateTime.tryParse(json['lastReview'].toString()) : null,
      priority: json['priority'] is int ? json['priority'] : 1,
      stability: (json['stability'] as num?)?.toDouble() ?? 1.0,
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 5.0,
      reviewCount: json['reviewCount'] is int ? json['reviewCount'] : 0,
    );
  }
}
