import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/utilities/generative_content.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class QuestionData {
  final String question;
  final String answer;
  final String modified;
  final int wrongWordsCount;

  QuestionData({
    required this.question,
    required this.answer,
    required this.wrongWordsCount,
    required this.modified,
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

  // 特定のインデックスの質問の正解単語数を増やす
  Future<void> addAnswer(int page, String answerSentence) async {
    String questionSentence = state[page].question;

    String modifiedSentence = await GenerativeService().generateText(
        '以下の文章(1)は大学入試の英訳問題(2)の回答である。問題の回答として適切になるように文法と自然な言語使用の観点から修正を加えて。ただし入力が正しい場合は文章(1)を、間違っている場合は修正後の一文のみ答えること。： (1)$answerSentence (2)$questionSentence');
    int wrong = wrongWordsCount(answerSentence, modifiedSentence);
    state[page] = QuestionData(
      question: questionSentence,
      answer: answerSentence,
      wrongWordsCount: wrong,
      modified: modifiedSentence,
    );
  }

  void addAnswerAndScore(int page, String answerSentence) async {
    String questionSentence = state[page].question;
    String modifiedSentence = state[page].modified;
    int wrong = wrongWordsCount(answerSentence, modifiedSentence);
    state[page] = QuestionData(
      question: questionSentence,
      answer: answerSentence,
      wrongWordsCount: wrong,
      modified: modifiedSentence,
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
        print('1');
        int nextMatch = _findNextMatch(words1, words2, i, j);
        if (nextMatch == -1) {
          // No more matches, add all remaining words with underline
          while (j < words2.length) {
            j++;
            wrong++;
          }
          break;
        } else {
          // Add words up to the next match with underline
          while (j < nextMatch) {
            j++;
            wrong++;
          }
          print('2');
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
