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
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (value.clamp(0, 10)) / 10.0,
              backgroundColor: color.withOpacity(0.1),
              color: color,
              minHeight: 3,
            ),
          ),
        ),
        /*const SizedBox(width: 6),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
              color: Colors.grey[500], fontSize: 10, fontFamily: 'monospace'),
        ),*/
      ],
    );
  }
}
