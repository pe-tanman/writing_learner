import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/emoji_converter.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/screens/daily_challenge.dart';
import 'package:writing_learner/themes/app_theme.dart';
import 'package:writing_learner/provider/database_helper.dart';


class QuestionResultScreen extends ConsumerStatefulWidget {
  final int? materialId;
  final int startQuestionNum;
  final int endQuestionNum;
  final int startQuestionId;
  final bool isDailyChallenge;
  const QuestionResultScreen(this.materialId, this.startQuestionId,
      this.startQuestionNum, this.endQuestionNum, this.isDailyChallenge,
      {super.key});

  @override
  ConsumerState<QuestionResultScreen> createState() =>
      _QuestionResultScreenState();
}

class _QuestionResultScreenState extends ConsumerState<QuestionResultScreen> {
  var pastQuestions = [];
  var questionData;
  int materialId = 0;
  bool clear = false;
  QuestionDatabaseHelper dbHelper = QuestionDatabaseHelper();
  MaterialDatabaseHelper materialDbHelper = MaterialDatabaseHelper();
  DailyChallengeDatabaseHelper dailyChallengeDatabaseHelper =
      DailyChallengeDatabaseHelper();

  int averageAccuracy() {
    var sum = 0;
    for (QuestionData question in pastQuestions) {
      sum += question.wrongWordsCount;
    }
    return (sum ~/ pastQuestions.length).round();
  }

  List errorTags(questionList) {
    var result = [];
    for (var element in questionList) {
      var errors = element.errors;
      if (errors == null) {
        continue;
      }
      var errorStrList = [];
      for (var error in errors) {
        errorStrList.add(GrammarError.toErrorType(error.type));
      }
      var errorTagStr = errorStrList.join(',');
      result.add(errorTagStr);
    }
    return result;
  }

  void saveData() {
    for (var questionNum = widget.startQuestionNum;
        questionNum <= widget.endQuestionNum;
        questionNum++) {
      var data = questionData[questionNum];
      pastQuestions.add(data);
      List<int> errorTags = [];
      for (var element in data.errors) {
        errorTags.add(element.type);
      }

      if (widget.materialId != null) {
        dbHelper.updateAccuracyRateAndError(
            widget.materialId!,
            widget.startQuestionId + questionNum,
            data.wrongWordsCount,
            errorTags);
      } else {
        materialId = data.materialId;
        dbHelper.updateAccuracyRateAndError(
            materialId, questionNum, data.wrongWordsCount, errorTags);
      }
    }
    if (widget.materialId != null) {
      materialDbHelper.updateNextNumber(widget.materialId!,
          (widget.endQuestionNum + widget.startQuestionId + 1));
    } else {
      materialDbHelper.updateNextNumber(
          materialId, (widget.endQuestionNum + widget.startQuestionId + 1));
    }
  }

  void evaluateAndSaveDailyChallenge() {
    var accuracy = averageAccuracy();
    if (accuracy >= 60) {
      clear = true;
      print('clear');
      dailyChallengeDatabaseHelper.insertData(accuracy);
    } else {
      print('failed');
      clear = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    questionData = ref.watch(questionDataProvider);
    pastQuestions = [];

    //データ保存
    saveData();
    evaluateAndSaveDailyChallenge();
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        widget.isDailyChallenge
            ? EmojiConverter.convertAccuracyToPassFail(averageAccuracy())
            : EmojiConverter.convertAccuracyToImage(averageAccuracy()),
        const SizedBox(height: 40),
        Text(
          '結果詳細',
          style: appTheme().textTheme.headlineSmall,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: pastQuestions.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
            ),
            itemBuilder: (context, index) {
              final review = pastQuestions[index];
              return Card(
                child: ListTile(
                  trailing: Text(
                      EmojiConverter.convertAccuracyToEmoji(
                        pastQuestions[index].wrongWordsCount,
                      ),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 30)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pastQuestions[index].question!),
                      const SizedBox(height: 10),
                      Text('#${errorTags(pastQuestions)[index]}',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.isDailyChallenge)
          Column(
            children: clear
                ? [
                    primaryButton('ホームへ戻る', () {
                      Navigator.of(context).pop();
                      
                    }),
                    const SizedBox(height: 20),
                  ]
                : [
                    primaryButton('もう一度挑戦', () {
                      ref.watch(questionDataProvider.notifier).clearQuestions();
                      Navigator.of(context)
                          .pushNamed(DailyChallengeScreen.routeName);
                    }),
                    const SizedBox(height: 20),
                    secondaryButton('ホームへ戻る', () {
                      Navigator.of(context).pop();
                    }),
                    const SizedBox(height: 20),
                  ],
          ),
      ]),
    ));
  }
}
