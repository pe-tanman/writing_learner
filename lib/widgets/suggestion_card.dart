import 'package:flutter/material.dart';
import 'package:writing_learner/themes/app_theme.dart';

class SuggestionCard extends StatelessWidget {
  final String suggestion;
  final String errorTag;
  final String reason;
  final VoidCallback onApply;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.errorTag,
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
            (reason.isEmpty)?
            const CircularProgressIndicator():
            Column(
              children: [
                Text('#: $errorTag', style: appTheme().textTheme.headlineSmall),
                Text(reason),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
