import 'package:writing_learner/utilities/generative_content.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'question_provider.g.dart';

class QuestionData {
  final String question;
  final String answer;
  final String modified;
  final int correctWordsCount;

  QuestionData({
    required this.question,
    required this.answer,
    required this.correctWordsCount,
    required this.modified,
  });
}

@riverpod
class QuestionNotifier extends _$QuestionNotifier {
  @override
  List<QuestionData> build() {
    // 初期状態を返す
    return [];
  }

  // 新しい質問を追加
  void addQuestion(String questionSentence) {
    QuestionData questionData = QuestionData(
        question: questionSentence,
        answer: '',
        correctWordsCount: 0,
        modified: '');
    //TODO正しくstateが読み込めない。毎回[]を読み込んでしまう
    state = [...state, questionData];
    for (var data in state) {
      print(data.question);
    }
  }

  void addQuestionData(QuestionData questionData) {
    //TODO正しくstateが読み込めない。毎回[]を読み込んでしまう
    state = [...state, questionData];
    for (var data in state) {
      print(data.question);
    }
  }

  // すべての質問をクリア
  void clearQuestions() {
    state = [];
  }

  // 特定のインデックスの質問の正解単語数を増やす
  Future<void> addAnswer(int page, String answerSentence) async {
    String questionSentence = state[page].question;
    String modifiedSentence = await GenerativeService().generateText(
        '以下の文章(1)は大学入試の英訳問題(2)の回答である。問題の回答として適切になるように文法と自然な言語使用の観点から修正を加えて。ただし入力が正しい場合は文章(1)を、間違っている場合は修正後の一文のみ答えること。： (1)$answerSentence (2)$questionSentence');
    int correct = correctWordsCount(answerSentence, modifiedSentence);
    state[page] = QuestionData(
        question: questionSentence,
        answer: answerSentence,
        correctWordsCount: correct,
        modified: modifiedSentence);
  }

  void addAnswerAndScore(int page, String answerSentence) async {
    String questionSentence = state[page].question;
    String modifiedSentence = state[page].modified;
    int correct = correctWordsCount(answerSentence, modifiedSentence);
    state[page] = QuestionData(
        question: questionSentence,
        answer: answerSentence,
        correctWordsCount: correct,
        modified: modifiedSentence);
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
