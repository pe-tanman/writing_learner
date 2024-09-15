import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/themes/app_theme.dart';
import 'package:writing_learner/widgets/modify_answer_block.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class QuestionPage extends ConsumerStatefulWidget {
  const QuestionPage({super.key, required this.questionNum});
  final int questionNum;

  @override
  ConsumerState<QuestionPage> createState() => QuestionPageState();
}

class QuestionPageState extends ConsumerState<QuestionPage> {
  String answerSentence = '';
  bool showAnswer = false;
  @override
  Widget build(BuildContext context) {
    int questionNum = widget.questionNum;
    final questionData = ref.watch(questionDataProvider)[questionNum];

    final notifier = ref.read(questionDataProvider.notifier);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(questionData.question),
              const SizedBox(height: 15),
              TextField(
                autocorrect: false,
                maxLines: null,
                enabled: !ref.watch(isAnsweredProvider),
                enableSuggestions: false,
                decoration: const InputDecoration(hintText: "回答"),
                onChanged: (value) {
                  answerSentence = value;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () async{
                    if(ref.read(isAnsweredProvider)){
                      return;
                    }
                    setState(() {
                      showAnswer = true;
                    });
                    
                    await notifier.addAnswerAndModify(questionNum, answerSentence);
                    ref.read(isAnsweredProvider.notifier).state = true;
                    
                  },
                  child: const Text('答え合わせ')),
              Center(
                  child: showAnswer
                      ? Column(
                          children: [
                            ModifiedAnswerRichText(page: questionNum),
                            Text(
                                '正答率 :${questionData.wrongWordsCount}%'),
                                _getLinearGauge()                                
                          ],
                        )
                      : Container()),
            ],
          ),
        ),
      ),
    );
  }
    Widget _getLinearGauge() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: SfLinearGauge(
          minimum: 0.0,
          maximum: 100.0,
          orientation: LinearGaugeOrientation.horizontal,
          showTicks: false,
          showLabels: false,
          animateAxis: true,
          axisTrackStyle: LinearAxisTrackStyle(
            
              color: appTheme().primaryColor,
              edgeStyle: LinearEdgeStyle.bothFlat,
              thickness: 15.0,
              borderColor: Colors.grey)),
    );
  }
}
