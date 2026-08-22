import 'package:flutter_test/flutter_test.dart';
import 'package:wortschatz/core/models/flashcard.dart';
import 'package:wortschatz/features/learning/learning_controller.dart';

void main() {
  group('LearningController Tests', () {
    test('Rating.again resets reviewCount', () {
      final controller = LearningController();
      final card = Flashcard(
        front: 'a',
        back: 'b',
        reviewCount: 10,
        stability: 100.0,
      );
      final updatedCard = controller.answer(card, Rating.again);
      expect(updatedCard.reviewCount, 1);
      expect(updatedCard.nextReview.difference(DateTime.now()).inMinutes, closeTo(10, 1));
    });

    test('Rating.good follow steps', () {
      final controller = LearningController();
      var card = Flashcard(front: 'a', back: 'b', reviewCount: 0);
      card = controller.answer(card, Rating.good);
      expect(card.reviewCount, 1);
      card = controller.answer(card, Rating.good);
      expect(card.reviewCount, 2);
      card = controller.answer(card, Rating.good);
      expect(card.reviewCount, 3);
    });

    test('Priority Scaling', () {
      final controller = LearningController();
      final cardP1 = Flashcard(front: 'a', back: 'b', priority: 1, reviewCount: 0);
      final cardP2 = Flashcard(front: 'a', back: 'b', priority: 2, reviewCount: 0);

      final updatedP1 = controller.answer(cardP1, Rating.good);
      final updatedP2 = controller.answer(cardP2, Rating.good);

      final diffP1 = updatedP1.nextReview.difference(DateTime.now()).inMinutes;
      final diffP2 = updatedP2.nextReview.difference(DateTime.now()).inMinutes;

      expect(diffP2, lessThan(diffP1));
      expect(diffP2, closeTo(5, 1));
      expect(diffP1, closeTo(10, 1));
    });

    test('Difficulty Updates over several iterations', () {
      final controller = LearningController();
      var cardAgain = Flashcard(front: 'a', back: 'b', difficulty: 5.0);
      var cardEasy = Flashcard(front: 'a', back: 'b', difficulty: 5.0);

      for (int i = 0; i < 3; i++) {
        cardAgain = controller.answer(cardAgain, Rating.again);
        cardEasy = controller.answer(cardEasy, Rating.easy);
      }

      expect(cardAgain.difficulty, greaterThan(5.0));
      expect(cardEasy.difficulty, lessThan(5.0));
    });

    test('Stability Growth: Rating.good vs Rating.easy', () {
      final controller = LearningController();
      final baseCard = Flashcard(
        front: 'a',
        back: 'b',
        stability: 10.0,
        lastReview: DateTime.now().subtract(const Duration(days: 10)),
        reviewCount: 3,
      );

      final updatedGood = controller.answer(baseCard, Rating.good);
      final updatedEasy = controller.answer(baseCard, Rating.easy);

      expect(updatedEasy.stability, greaterThan(updatedGood.stability));
    });

    test('Transition to Stability-based intervals after 3rd review', () {
      final controller = LearningController();
      // Start at reviewCount 3, so answer() will make it 4.
      final card = Flashcard(
        front: 'a',
        back: 'b',
        reviewCount: 3,
        stability: 100.0,
        lastReview: DateTime.now().subtract(const Duration(days: 90)),
      );

      final updatedCard = controller.answer(card, Rating.good);

      expect(updatedCard.reviewCount, 4);
      // Stability based interval for 100 stability should be much larger than 72 hours (3 days).
      // nextInterval = stability * (pow(0.9, 1/-0.5) - 1) / exp(-0.5)
      // 1/-0.5 = -2. 0.9^-2 = 1.2345. 1.2345 - 1 = 0.2345.
      // exp(-0.5) = 0.6065. 0.2345 / 0.6065 = 0.3866.
      // interval = 100 * 0.3866 = 38.66 days.
      final daysDiff = updatedCard.nextReview.difference(DateTime.now()).inDays;
      expect(daysDiff, greaterThan(30));
    });

    test('Rating.hard vs Rating.good', () {
      final controller = LearningController();
      final baseCard = Flashcard(
        front: 'a',
        back: 'b',
        stability: 10.0,
        lastReview: DateTime.now().subtract(const Duration(days: 10)),
        reviewCount: 3,
      );

      final updatedHard = controller.answer(baseCard, Rating.hard);
      final updatedGood = controller.answer(baseCard, Rating.good);

      expect(updatedHard.stability, lessThan(updatedGood.stability));
      expect(updatedHard.difficulty, greaterThan(updatedGood.difficulty));
      
      final daysHard = updatedHard.nextReview.difference(DateTime.now()).inDays;
      final daysGood = updatedGood.nextReview.difference(DateTime.now()).inDays;
      expect(daysHard, lessThan(daysGood));
    });
  });
}
