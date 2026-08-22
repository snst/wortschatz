import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/models/flashcard.dart';
import '../../core/widgets/summary_item.dart';

class StatisticsView extends StatelessWidget {
  final List<Flashcard> cards;

  const StatisticsView({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deck Statistics')),
        body: const Center(child: Text('No cards in database.')),
      );
    }

    final activeCount = cards.where((c) => c.priority > 0).length;
    final postponedCount = cards.where((c) => c.priority == 0).length;
    final learning = cards.where((c) => c.reviewCount > 0).toList();
    final avgDifficulty = learning.isEmpty ? 0.0 : learning.map((c) => c.difficulty).reduce((a, b) => a + b) / learning.length;
    final avgStability = learning.isEmpty ? 0.0 : learning.map((c) => c.stability).reduce((a, b) => a + b) / learning.length;
    
    final now = DateTime.now();
    double totalRetention = 0;
    for (var card in learning) {
      final t = now.difference(card.lastReview).inDays;
      final r = pow(0.9, t / max(card.stability, 0.1));
      totalRetention += r;
    }
    final avgRetention = learning.isEmpty ? 0.0 : totalRetention / learning.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCompactSummary(context, cards.length, activeCount, postponedCount, avgStability, avgDifficulty, avgRetention),
            const SizedBox(height: 24),

            Expanded(
              child: StabilityDifficultyHeatmap(cards: learning),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Difficulty (1-10) →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSummary(BuildContext context, int total, int active, int postponed, double stability, double difficulty, double retention) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SummaryItem(label: 'Active', value: '$active'),
            SummaryItem(label: 'Postponed', value: '$postponed'),
            SummaryItem(label: 'Stability', value: '${stability.toStringAsFixed(1)}d'),
            SummaryItem(label: 'Difficulty', value: difficulty.toStringAsFixed(1)),
            SummaryItem(label: 'Recall', value: '${(retention * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }
}

class StabilityDifficultyHeatmap extends StatelessWidget {
  final List<Flashcard> cards;

  const StabilityDifficultyHeatmap({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const Center(child: Text('No learning data yet.'));

    final stabRanges = [1, 3, 7, 14, 30, 90, 365, 10000];
    final grid = List.generate(8, (_) => List.generate(10, (_) => 0));

    for (var card in cards) {
      int dIdx = (card.difficulty.clamp(1, 10) - 1).floor();
      int sIdx = stabRanges.indexWhere((r) => card.stability <= r);
      if (sIdx == -1) sIdx = 7;
      grid[sIdx][dIdx]++;
    }

    int maxCount = 0;
    for (var row in grid) {
      for (var val in row) {
        if (val > maxCount) maxCount = val;
      }
    }

    return Row(
      children: [
        // Y-Axis (Stability)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Stab.', style: TextStyle(fontSize: 8, color: Colors.grey)),
            ...stabRanges.reversed.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(r > 365 ? '1y+' : '${r}d', style: const TextStyle(fontSize: 10)),
            )),
            const SizedBox(height: 10),
          ],
        ),
        const SizedBox(width: 8),
        // Grid
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: List.generate(8, (y) {
                    final reverseY = 7 - y;
                    return Expanded(
                      child: Row(
                        children: List.generate(10, (x) {
                          final count = grid[reverseY][x];
                          final opacity = maxCount > 0 ? count / maxCount : 0.0;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.05 + opacity * 0.95),
                                borderRadius: BorderRadius.circular(3),
                                border: count > 0 ? Border.all(color: Colors.white.withOpacity(0.2), width: 0.5) : null,
                              ),
                              child: count > 0 
                                ? Center(child: Text('$count', style: TextStyle(fontSize: 10, color: opacity > 0.5 ? Colors.white : Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))) 
                                : null,
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 4),
              // X-Axis Labels (Difficulty)
              Row(
                children: List.generate(10, (i) => Expanded(child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 10))))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
