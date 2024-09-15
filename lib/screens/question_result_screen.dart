import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/themes/app_color.dart';
import 'package:writing_learner/provider/database_helper.dart';

class QuestionResultScreen extends ConsumerStatefulWidget {
  final int materialId;
  final int startQuestionNum;
  final int endQuestionNum;
  final int startQuestionId;
  const QuestionResultScreen(this.materialId, this.startQuestionId,
      this.startQuestionNum, this.endQuestionNum,
      {super.key});

  @override
  ConsumerState<QuestionResultScreen> createState() =>
      _QuestionResultScreenState();
}

class _QuestionResultScreenState extends ConsumerState<QuestionResultScreen> {
  var pastQuestions = [];
  var questionData;
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
      print("questionNum$questionNum");
      var data = questionData[questionNum];
      pastQuestions.add(data);

      dbHelper.updateAccuracyRate(widget.materialId,
          widget.startQuestionId + questionNum, data.wrongWordsCount);
    }
    print("pastQuestions$pastQuestions");
    print(
        'nextQuestionId${widget.endQuestionNum + widget.startQuestionId + 1}');

    materialDbHelper.updateNextNumber(widget.materialId,
        (widget.endQuestionNum + widget.startQuestionId + 1));

    List<TableCell> countTableRow = pastQuestions.map((question) {
      return TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(question.wrongWordsCount.toString())),
        ),
      );
    }).toList();
    List<TableCell> numTableRow =
        Iterable<int>.generate(3, (i) => i + 1).map((number) {
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
        )
      ]),
    ));
  }
}
