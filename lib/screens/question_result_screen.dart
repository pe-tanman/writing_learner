import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/question_provider.dart';

class QuestionResultScreen extends ConsumerStatefulWidget {
  const QuestionResultScreen({super.key});

  @override
  ConsumerState<QuestionResultScreen> createState() =>
      _QuestionResultScreenState();
}

class _QuestionResultScreenState extends ConsumerState<QuestionResultScreen> {
  var pastQuestions = [];

  @override
  Widget build(BuildContext context) {
    final questionData = ref.watch(questionDataProvider);
    pastQuestions =
        questionData.sublist(questionData.length - 6, questionData.length - 1);

    List<TableCell> countTableRow = pastQuestions.map((question) {
      return TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text(question.wrongWordsCount.toString())),
        ),
      );
    }).toList();
    List<TableCell> numTableRow =
        Iterable<int>.generate(5, (i) => i + 1).map((number) {
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
          child: Column(children: [
                const Text('右スワイプで次の問題へ'),
                const SizedBox(height: 20),
                Table(
          border: TableBorder.all(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          children: [const TableCell(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('#')),
          ))] + numTableRow,
            ),
            TableRow(
          children: [const TableCell(child:Padding(
            padding: EdgeInsets.all(8),
            child: 
              Center(child: Text('間違い')),
            
          ))] + countTableRow,
            ),
          ],
                )
              ]),
        ));
  }
}
