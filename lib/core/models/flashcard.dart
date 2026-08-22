import '../database/database.dart';

class Flashcard {
  final int id;
  final String front;
  final String back;
  final String note;
  final DateTime nextReview;
  final DateTime lastReview;
  final int priority;
  final double stability;
  final double difficulty;
  final int reviewCount;

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

  Flashcard copyWith({
    int? id,
    String? front,
    String? back,
    String? note,
    DateTime? nextReview,
    DateTime? lastReview,
    int? priority,
    double? stability,
    double? difficulty,
    int? reviewCount,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      note: note ?? this.note,
      nextReview: nextReview ?? this.nextReview,
      lastReview: lastReview ?? this.lastReview,
      priority: priority ?? this.priority,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'note': note,
      'nextReview': nextReview.toIso8601String(),
      'lastReview': lastReview.toIso8601String(),
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
