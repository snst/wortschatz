import 'package:flutter_test/flutter_test.dart';
import 'package:wortschatz/flashcard.dart';

void main() {
  test('Simple increment test', () {
    final card = Flashcard(front: 'a', back: 'b');
    expect(card.reviewCount, 0);
    card.reviewCount += 1;
    expect(card.reviewCount, 1);
  });
}
