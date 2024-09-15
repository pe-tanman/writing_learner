import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/utilities/generative_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class QuestionData {
  final String question;
  final String answer;
  final String modified;
  final int wrongWordsCount;
  final String? fillingQuestion;
  final List<String>? fillingAnswers;
  final List<GrammarError> errors;

  QuestionData({
    required this.question,
    required this.answer,
    required this.wrongWordsCount,
    required this.modified,
    required this.errors,
    this.fillingQuestion,
    this.fillingAnswers,
  });
}

class GrammarError {
  final String original;
  final String suggestion;
  final String reason;

  GrammarError({
    required this.original,
    required this.suggestion,
    required this.reason,
  });
}

@riverpod
class QuestionDataNotifier extends StateNotifier<List<QuestionData>> {
  QuestionDataNotifier() : super([]);

  // 新しい質問を追加
  void addQuestionSentence(String questionSentence) {
    QuestionData questionData = QuestionData(
      question: questionSentence,
      answer: '',
      wrongWordsCount: 0,
      modified: '',
      errors: [],
    );
    state = [...state, questionData];
  }

  void addQuestionData(QuestionData questionData) {
    state = [...state, questionData];
  }

  // すべての質問をクリア
  void clearQuestions() {
    state = [];
  }

  // ユーザーの回答を記録＋修正
  Future<void> addAnswerAndModify(int page, String answerSentence) async {
    List<GrammarError> errors = [];

    String questionSentence = state[page].question;
    var output = await GenerativeService()
        .generateReasonMaps(questionSentence, answerSentence);
    var errorMap = output['error_array'];
    var modifiedSentence = output['modified_sentence'];
    int wrong = wrongWordsPercent(answerSentence, modifiedSentence);
    for (int i = 0; i <= errorMap.length - 1; i++) {
      var error = errorMap[i];
      var original = error['original_phrase'];
      var suggestion = error['suggested_phrase'];
      var reason = error['reason'];
      errors.add(GrammarError(
          original: original, suggestion: suggestion, reason: reason));
    }
    state[page] = QuestionData(
        question: questionSentence,
        answer: answerSentence,
        wrongWordsCount: wrong,
        modified: modifiedSentence,
        errors: errors);
  }

//すでに答えが設定してある場合に使用
  void addAnswerAndScore(int page, String answerSentence) async {
    String questionSentence = state[page].question;
    String modifiedSentence = state[page].modified;
    String? fillingQuestion = state[page].fillingQuestion;
    int wrong = wrongWordsPercent(answerSentence, modifiedSentence);
    state[page] = QuestionData(
        question: questionSentence,
        answer: answerSentence,
        wrongWordsCount: wrong,
        modified: modifiedSentence,
        fillingQuestion: fillingQuestion,
        errors: []);
    //TODO:errorsを追加する
    //isAnsweredが変化してもbuild treeで反応しない→反応させる方法はあるか、別の方法（isAnsweredProviderをリストにする）or currentPageみたいなのをつけることでそこまでは一括で回答済みにする＋isAnsweredProvider戻れる必要性がない
  }

  int wrongWordsPercent(var answerSentence, var modifiedSentence) {
    List<String> words1 = answerSentence.split(' ');
    List<String> words2 = modifiedSentence.split(' ');
    int i = 0, j = 0, wrong = 0;
    while (i < words1.length || j < words2.length) {
      if (i < words1.length && j < words2.length && words1[i] == words2[j]) {
        i++;
        j++;
      } else {
        // Find the next matching word
        int nextMatch = _findNextMatch(words1, words2, i, j);

        if (nextMatch == -1) {
          while (j < words2.length) {
            wrong++;
            j++;
          }
          break;
        } else {
          while (j < nextMatch) {
            wrong++;
            j++;
          }
          i = words1.indexOf(words2[nextMatch], i);
        }
      }
    }
    var percent = (100 - (wrong / modifiedSentence.length * 100)).round();
    return percent;
  }

  int _findNextMatch(
      List<String> words1, List<String> words2, int start1, int start2) {
    for (int k = start2; k < words2.length; k++) {
      if (words1.sublist(start1, words1.length).contains(words2[k])) {
        return k;
      }
    }
    return -1;
  }
}

final questionDataProvider =
    StateNotifierProvider<QuestionDataNotifier, List<QuestionData>>(
        (ref) => QuestionDataNotifier());
