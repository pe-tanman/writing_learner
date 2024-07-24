import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/utilities/generative_content.dart';


class Question {
  final String question;
  final String answer;
  final String modified;
  final int correctAnswerIndex;

  Question({
    required this.question,
    required this.correctAnswerIndex,
    required this.answer,
    required this.modified,
  });
}

/*class QuizState {
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final int score;

  QuizState({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.score = 0,
  });

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    int? score,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
    );
  }
}*/

final questionProvider =
    StateNotifierProvider<QuestionNotifier, List<Question>>((ref) {
  return QuestionNotifier();
});

class QuestionNotifier extends StateNotifier<List<Question>> {
  QuestionNotifier() : super([]);
  

  Future<String> generateModifiedAnswer(
      var questionSentence, var answerSentence) async {
    String modifiedSentence = await GenerativeService().generateText(
        '以下の文章(1)は大学入試の英訳問題(2)の回答である。問題の回答として適切になるように文法と自然な言語使用の観点から修正を加えて。ただし入力が正しい場合は文章(1)を、間違っている場合は修正後の一文のみ答えること。： (1)$answerSentence (2)$questionSentence');
    return modifiedSentence;
  }
   int correctWordsCount(var answerSentence, var modifiedSentence) {
    List<String> words1 = answerSentence.split(' ');
    List<String> words2 = modifiedSentence.split(' ');

    int i = 0, j = 0, correct = 0;
    while (i < words1.length || j < words2.length) {
      if (i < words1.length && j < words2.length && words1[i] == words2[j]) {
        i++;
        j++;
        correct++;
      } else {
        // Find the next matching word
        int nextMatch = _findNextMatch(words1, words2, i, j);
        if (nextMatch == -1) {
          // No more matches, add all remaining words with underline
          while (j < words2.length) {
            j++;
          }
          break;
        } else {
          // Add words up to the next match with underline
          while (j < nextMatch) {
            j++;
          }
          i = words1.indexOf(words2[nextMatch], i);
        }
      }
    }
    return correct;
  }

  int _findNextMatch(
      List<String> words1, List<String> words2, int start1, int start2) {
    for (int i = start2; i < words2.length; i++) {
      if (words1.contains(words2[i])) {
        return i;
      }
    }
    return -1;
  }
}
