import 'package:flutter_test/flutter_test.dart';
import '../lib/flashcard.dart';
import '../lib/learning_controller.dart';

void main() {
  group('LearningController Tests', () {
    test('Rating.again resets reviewCount', () {
      final controller = LearningController();
      final card = Flashcard(front: 'a', back: 'b');
      card.reviewCount = 10;
      card.stability = 100.0;
      controller.answer(card, Rating.again);
      expect(card.reviewCount, 1);
      expect(card.nextReview.difference(DateTime.now()).inMinutes, closeTo(10, 1));
    });

    test('Rating.good follow steps', () {
      final controller = LearningController();
      final card = Flashcard(front: 'a', back: 'b');
      card.reviewCount = 0;
      controller.answer(card, Rating.good);
      expect(card.reviewCount, 1);
      controller.answer(card, Rating.good);
      expect(card.reviewCount, 2);
      controller.answer(card, Rating.good);
      expect(card.reviewCount, 3);
    });
  });
}
