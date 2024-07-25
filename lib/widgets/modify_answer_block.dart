import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/question_provider.dart';

class ModifiedAnswerRichText extends ConsumerWidget {
  final int page;

  // コンストラクタで引数を受け取る
  ModifiedAnswerRichText({super.key, required this.page});

  bool isLoading = true;

  int _findNextMatch(
      List<String> words1, List<String> words2, int start1, int start2) {
    for (int i = start2; i < words2.length; i++) {
      if (words1.contains(words2[i])) {
        return i;
      }
    }
    return -1;
  }

  List<InlineSpan> spans(String answerSentence, String modifiedSentence) {
    List<String> words1 = answerSentence.split(' ');
    List<String> words2 = modifiedSentence.split(' ');
    List<InlineSpan> spans = [];

    int i = 0, j = 0;
    while (i < words1.length || j < words2.length) {
      if (i < words1.length && j < words2.length && words1[i] == words2[j]) {
        spans.add(TextSpan(
            text: '${words2[j]} ',
            style: const TextStyle(
                fontSize: 15,
                decoration: TextDecoration.none,
                color: Colors.black)));
        i++;
        j++;
      } else {
        // Find the next matching word
        int nextMatch = _findNextMatch(words1, words2, i, j);
        if (nextMatch == -1) {
          // No more matches, add all remaining words with underline
          while (j < words2.length) {
            spans.add(TextSpan(
              text: '${words2[j]} ',
              style: const TextStyle(
                  fontSize: 15, decoration: TextDecoration.underline),
            ));
            j++;
          }
          break;
        } else {
          // Add words up to the next match with underline
          while (j < nextMatch) {
            spans.add(TextSpan(
              text: '${words2[j]} ',
              style: const TextStyle(
                  fontSize: 15, decoration: TextDecoration.underline),
            ));
            j++;
          }
          i = words1.indexOf(words2[nextMatch], i);
        }
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionData = ref.watch(questionNotifierProvider)[page];
    isLoading = questionData.modified == '';
    return isLoading
        ? const CircularProgressIndicator()
        : RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: spans(questionData.answer, questionData.modified),
            ),
          );
  }
}
