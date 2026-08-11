import 'dart:math';

import 'flashcard.dart';

enum Rating { again, hard, good, easy }

class LearningController {
  final double desiredRetention = 0.90;
  final double decay = -0.5;

  void answer(Flashcard card, Rating rating) {
    final now = DateTime.now();
    final daysElapsed = max(0, now.difference(card.lastReview).inDays);

    card.stability = max(1.0, card.stability);
    final retrievability = _calculateRetrievability(card.stability, daysElapsed);

    card.difficulty = _updateDifficulty(card.difficulty, rating);

    if (rating == Rating.again) {
      card.reviewCount = 0;
    }

    card.stability = _nextStability(card.stability, card.difficulty, retrievability, rating);

    card.reviewCount++;
    card.lastReview = now;

    if (card.reviewCount == 1) {
      card.nextReview = now.add(const Duration(minutes: 10));
      return;
    }

    if (card.reviewCount == 2) {
      card.nextReview = now.add(const Duration(days: 1));
      return;
    }

    if (card.reviewCount == 3) {
      card.nextReview = now.add(const Duration(days: 3));
      return;
    }

    final interval = calculateNextInterval(card);
    card.nextReview = now.add(Duration(days: interval));
  }

  double _calculateRetrievability(double stability, int daysElapsed) {
    if (daysElapsed == 0) return 1.0;
    return pow(1 + exp(decay) * (daysElapsed / stability), 1 / decay).toDouble();
  }

  double _updateDifficulty(double difficulty, Rating rating) {
    double change = 0;
    switch (rating) {
      case Rating.again: change = 0.5; break;
      case Rating.hard: change = 0.15; break;
      case Rating.good: change = -0.10; break;
      case Rating.easy: change = -0.20; break;
    }
    const meanDifficulty = 5.0;
    final updated = (difficulty + change) * 0.95 + meanDifficulty * 0.05;
    return updated.clamp(1.0, 10.0);
  }

  double _nextStability(double stability, double difficulty, double retrievability, Rating rating) {
    if (rating == Rating.again) {
      return max(1.0, sqrt(stability));
    }
    final difficultyFactor = exp(-0.1 * (difficulty - 1));
    final multiplier = switch (rating) {
      Rating.hard => 0.8,
      Rating.good => 1.0,
      Rating.easy => 1.3,
      Rating.again => 0.0,
    };
    final forgetting = min(0.95, 1.0 - retrievability);
    final growth = max(1.05, 1 + 2 * forgetting * difficultyFactor * multiplier);
    return stability * growth;
  }

  int calculateNextInterval(Flashcard card) {
    final interval = card.stability * (pow(desiredRetention, 1 / decay) - 1) / exp(decay);
    return interval.round().clamp(1, 36500);
  }
}
