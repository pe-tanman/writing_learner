import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/widgets/modify_answer_block.dart';

class FillingQuestionPage extends ConsumerStatefulWidget {
  const FillingQuestionPage({super.key, required this.questionNum});
  final int questionNum;

  @override
  ConsumerState<FillingQuestionPage> createState() =>
      FillingQuestionPageState();
}

class FillingQuestionPageState extends ConsumerState<FillingQuestionPage> {
  String answerSentence = '';
  bool showAnswer = false;
  List<TextEditingController?> _controllers = [];
  bool isInit = true;
  var questionWords = [];

  List<InlineSpan> buildSpans(String sentence) {
    List<InlineSpan> spans = [];

    questionWords = sentence.split(' ');

    for (var i = 0; i < questionWords.length; i++) {
      if (questionWords[i].contains('___')) {
        _controllers!.add(TextEditingController());
        spans.add(WidgetSpan(
            child: SizedBox(
                width: 80,
                child: TextField(
                    controller: _controllers[i],
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    )))));
      } else {
        _controllers.add(null);
        spans.add(TextSpan(
            text: questionWords[i],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            )));
      }

      if (i != questionWords.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }
    return spans;
  }

  String? convertToAnswerSentence() {
    String sentence = '';

    for (var i = 0; i < questionWords.length; i++) {
      //穴の場合
      if (_controllers[i] != null) {
        //空欄の場合
        if (_controllers[i]!.text.isEmpty) {
          SnackBar snackBar =
              const SnackBar(content: Text('入力されていないフィールドがあります'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return null;
        } else {
          sentence += _controllers[i]!.text;
        }
      } else {
        sentence += questionWords[i];
      }
      if (i != _controllers.length - 1) {
        sentence += ' ';
      }
    }
    return sentence;
  }

  @override
  Widget build(BuildContext context) {
    int questionNum = widget.questionNum;
    final questionData = ref.watch(questionDataProvider)[questionNum];

    final notifier = ref.read(questionDataProvider.notifier);
    if (isInit) {
      _controllers = [];
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('${questionData.question}'),
              const SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: buildSpans(questionData.fillingQuestion!),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (ref.read(isAnsweredProvider)) {
                      return;
                    }
                    if (convertToAnswerSentence() == null) {
                      return;
                    }
                    else{
                      if (ref.read(isAnsweredProvider)) {
                        return;
                      }
                      else{
setState(() {
                          showAnswer = true;
                        });

                         notifier.addAnswerAndScore(
                            questionNum, convertToAnswerSentence()!);
                        ref.read(isAnsweredProvider.notifier).state = true;
                      }
                    } 
                  },
                  child: Text('答え合わせ')),
              Center(
                  child: showAnswer
                      ? Column(
                          children: [
                            ModifiedAnswerRichText(page: questionNum),
                            Text(
                                '間違い :${questionData.wrongWordsCount.toString()}')
                          ],
                        )
                      : Container()),
            ],
          ),
        ),
      ),
    );
  }
}
