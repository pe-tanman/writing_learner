import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/utilities/generative_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';

class QuestionData {
  final String question;
  final int materialId;
  final String answer;
  final String modified;
  final int wrongWordsCount;
  final String? fillingQuestion;
  final List<String>? fillingAnswers;
  final List<GrammarError> errors;

  QuestionData({
    required this.materialId,
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
  final int type;
  final String detailedReason;

  GrammarError({
    required this.original,
    required this.suggestion,
    required this.type,
    required this.detailedReason,
  });

  static String toErrorType(int tag) {
    var errorTags = [
      'スペルミス',
      '複数形のミス',
      '三単現のミス',
      '完了形の使用ミス',
      '不定詞の使用ミス', '前置詞の使用ミス', '冠詞の使用ミス', '代名詞の使用ミス', '時制のミス', 'ニュアンスについて不自然な表現', 'あまり使われない不自然な表現', '記号の使い方のミス', '名詞のミス', 'その他のミス'];
      return errorTags[tag];
  }
}

@riverpod
class QuestionDataNotifier extends StateNotifier<List<QuestionData>> {
  QuestionDataNotifier() : super([]);

  // 新しい質問を追加
  void addQuestionSentence(int materialId, String questionSentence) {
    QuestionData questionData = QuestionData(
      materialId: materialId,
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
    int wrong = countDifferentPercent(answerSentence, modifiedSentence);
    for (int i = 0; i <= errorMap.length - 1; i++) {
      var error = errorMap[i];
      var original = error['original_phrase'];
      var suggestion = error['suggested_phrase'];
      var type = error['type'];
      var reason = error['reason'];
      errors.add(GrammarError(
          original: original, suggestion: suggestion, type:type, detailedReason: reason));
    }
    state[page] = QuestionData(
        materialId: state[page].materialId,
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
    int materialId = state[page].materialId;
    int wrong = countDifferentPercent(answerSentence, modifiedSentence);
    state[page] = QuestionData(
        materialId: materialId,
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
    print(answerSentence);
    print(modifiedSentence);
    List<String> words1 = answerSentence.split(' ');
    List<String> words2 = modifiedSentence.split(' ');
    int i = 0, j = 0, wrong = 0;
    while (i < words1.length || j < words2.length) {
      print('i:$i, j:$j');
      print('wrong:$wrong');
      if (i < words1.length && j < words2.length && words1[i] == words2[j]) {
        i++;
        j++;
      } else {
        // Find the next matching word
        int nextMatch1 = _findNextMatch(words1, words2, i, j);
        int nextMatch2 = _findNextMatch(words2, words1, j, i);
        if (nextMatch1 == -1&&nextMatch2==-1) {
          while (j < words2.length) {
            wrong++;
            j++;
          }
          break;
        } else {
          int nextMatch = nextMatch1 < nextMatch2 ? nextMatch1 : nextMatch2;
          while (j <= nextMatch) {
            wrong++;
            j++;
          }
          i = words1.indexOf(words2[nextMatch], i);
        }
      }
    }
    print('wrong:$wrong');
    print('modifiedSentence.length:${words2.length}');
    var percent = (100 - (wrong / words2.length) * 100).round();
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

  
  int countDifferentPercent(String sentence1, String sentence2) {
  int differentWordCount = 0;

    String sentence1_low = sentence1.toLowerCase();
    String sentence2_low = sentence2.toLowerCase();

    Set<String> words1 = sentence1_low.split(RegExp(r'\W+'))
        .where((word) => word.isNotEmpty).toSet();
    Set<String> words2 = sentence2_low.split(RegExp(r'\W+'))
        .where((word) => word.isNotEmpty).toSet();

    Set<String> differentWords = words1.difference(words2).union(words2.difference(words1));
    print('differentWords:$differentWords');
    differentWordCount = differentWords.length;
     var percent = (100 - (differentWordCount / words2.length) * 100).round();
    return percent;
}

final questionDataProvider =
    StateNotifierProvider<QuestionDataNotifier, List<QuestionData>>(
        (ref) => QuestionDataNotifier());
