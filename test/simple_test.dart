import 'package:flutter_test/flutter_test.dart';
import 'package:wortschatz/core/models/flashcard.dart';

void main() {
  test('Simple increment test', () {
    final card = Flashcard(front: 'a', back: 'b');
    expect(card.reviewCount, 0);
    final updatedCard = card.copyWith(reviewCount: card.reviewCount + 1);
    expect(updatedCard.reviewCount, 1);
  });
}
