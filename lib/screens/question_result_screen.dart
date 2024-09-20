import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/themes/app_color.dart';
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
  QuestionDatabaseHelper dbHelper = QuestionDatabaseHelper();
  MaterialDatabaseHelper materialDbHelper = MaterialDatabaseHelper();

  @override
  Widget build(BuildContext context) {
    final questionData = ref.watch(questionDataProvider);
    pastQuestions = [];

    //データ保存
    for (var questionNum = widget.startQuestionNum;
        questionNum <= widget.endQuestionNum;
        questionNum++) {
      var data = questionData[questionNum];
      pastQuestions.add(data);
      List<int> errorTags = [];
      data.errors.forEach((element) {
        errorTags.add(element.type);
      });

      if (widget.materialId != null) {
        
        dbHelper.updateAccuracyRateAndError(widget.materialId!,
            widget.startQuestionId + questionNum, data.wrongWordsCount, errorTags);
      } else {
        materialId = data.materialId;
        dbHelper.updateAccuracyRateAndError(
            materialId, questionNum, data.wrongWordsCount, errorTags );
      }
    }
    if (widget.materialId != null) {
      materialDbHelper.updateNextNumber(widget.materialId!,
          (widget.endQuestionNum + widget.startQuestionId + 1));
    } else {
      materialDbHelper.updateNextNumber(materialId,( widget.endQuestionNum + widget.startQuestionId + 1));
    }

    List<TableCell> countTableRow = pastQuestions.map((question) {
      return TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(question.wrongWordsCount.toString())),
        ),
      );
    }).toList();
    List<TableCell> numTableRow =
        Iterable<int>.generate(widget.endQuestionNum-widget.startQuestionNum+1, (i) => i + 1).map((number) {
      return TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(number.toString())),
        ),
      );
    }).toList();

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('lib/assets/l01_rectangle.png'),
        const SizedBox(height: 20),
        Table(
          border: const TableBorder(
            verticalInside: BorderSide(width: 0.7),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.themeColor.withAlpha(100),
              ),
              children: [
                    const TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text('#')),
                    ))
                  ] +
                  numTableRow,
            ),
            TableRow(
              children: [
                    const TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text('正答率')),
                    ))
                  ] +
                  countTableRow,
            ),
          ],
        ),
        SizedBox(height: 30),
        if(widget.isDailyChallenge)
         ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentColor),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ホームに戻る',style:TextStyle(color: Colors.white, fontSize: 22))),
      ]),
    ));
  }
}
