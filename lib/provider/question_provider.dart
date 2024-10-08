import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/utilities/generative_content.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class QuestionData {
  final String question;
  final String answer;
  final String modified;
  final int wrongWordsCount;
  final String? fillingQuestion;
  final List<String>? fillingAnswers;

  QuestionData({
    required this.question,
    required this.answer,
    required this.wrongWordsCount,
    required this.modified,
    this.fillingQuestion,
    this.fillingAnswers,
  });
}

class GrammarError {
  final int start;
  final int end;
  final List<String> original;
  final List<String> suggestion;
  String oritinalStr;
  String suggestedStr;
  String reason = '';

  GrammarError(
      {required this.start,
      required this.end,
      required this.original,
      required this.suggestion})
      : oritinalStr = original.join(' '),
        suggestedStr = suggestion.join(' ');
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
    String questionSentence = state[page].question;

    String modifiedSentence = await GenerativeService().generateModifiedSentence(questionSentence, answerSentence);
    int wrong = wrongWordsCount(answerSentence, modifiedSentence);
    state[page] = QuestionData(
      question: questionSentence,
      answer: answerSentence,
      wrongWordsCount: wrong,
      modified: modifiedSentence,
    );
  }
//すでに答えが設定してある場合に使用
  void addAnswerAndScore(int page, String answerSentence) async {
    String questionSentence = state[page].question;
    String modifiedSentence = state[page].modified;
    String? fillingQuestion = state[page].fillingQuestion;
    int wrong = wrongWordsCount(answerSentence, modifiedSentence);
    state[page] = QuestionData(
      question: questionSentence,
      answer: answerSentence,
      wrongWordsCount: wrong,
      modified: modifiedSentence,
      fillingQuestion: fillingQuestion
    );
    //isAnsweredが変化してもbuild treeで反応しない→反応させる方法はあるか、別の方法（isAnsweredProviderをリストにする）or currentPageみたいなのをつけることでそこまでは一括で回答済みにする＋isAnsweredProvider戻れる必要性がない
  }

  int wrongWordsCount(var answerSentence, var modifiedSentence) {
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
    return wrong;
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
