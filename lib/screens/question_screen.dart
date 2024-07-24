import 'package:flutter/material.dart';
import 'package:writing_learner/utilities/generative_content.dart';
import 'package:writing_learner/widgets/modify_answer_block.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key, required this.question}) : super(key: key);
  static const routeName = 'question-screen';
  final String question;
  @override
  State<QuestionScreen> createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen> {
  late String questionSentence;
  var answerSentence = '';
  var modifiedSentence = '下スワイプで答え合わせ';

  bool isInit = false;
  bool answered = false;

  int correct = 0;

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      questionSentence = widget.question;
    }
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              Text('問題文:\n$questionSentence'),
              const SizedBox(height: 15),
              TextField(
                autocorrect: false,
                maxLines: null,
                enabled: !answered,
                enableSuggestions: false,
                decoration: const InputDecoration(hintText: "回答"),
                onChanged: (value) {
                  answerSentence = value;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: (detail) {
                  answered = true;
                  correct = GenerativeService()
                      .correctWordsCount(answerSentence, modifiedSentence);
                },
                child: Container(
                  height: 200,
                  width: 500,
                  color: Colors.grey,
                  child: Center(
                      child: Column(
                    children: [
                      if (answered)
                        ModifiedAnswerRichText(
                            question: questionSentence, answer: answerSentence),
                      if (answered) Text('正解語数 :${correct.toString()}')
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
