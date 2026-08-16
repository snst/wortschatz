import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
            Text(value.toStringAsFixed(2), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value.clamp(0, 10)) / 10.0,
            backgroundColor: color.withOpacity(0.2),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
