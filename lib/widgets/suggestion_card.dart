import 'package:flutter/material.dart';

class SuggestionCard extends StatelessWidget {
  final String suggestion;
  final String reason;
  final VoidCallback onApply;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.reason,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Suggestion: $suggestion'),
            Text('Reason: $reason'),
            TextButton(
              onPressed: onApply,
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
