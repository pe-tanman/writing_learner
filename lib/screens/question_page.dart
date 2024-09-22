import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/emoji_converter.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/themes/app_theme.dart';
import 'package:writing_learner/widgets/modify_answer_block.dart';

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
                height: 30,
              ),
              primaryButton('答え合わせ', ()async{
                    if(ref.read(isAnsweredProvider)){
                      return;
                    }
                    setState(() {
                      showAnswer = true;
                    });
                    
                    await notifier.addAnswerAndModify(questionNum, answerSentence);
                    ref.read(isAnsweredProvider.notifier).state = true;
                    
                  }),
              Center(
                  child: showAnswer
                      ? Column(
                          children: [
                            ModifiedAnswerRichText(page: questionNum),                          
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
