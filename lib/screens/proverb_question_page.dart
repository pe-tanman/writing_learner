import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/widgets/modify_answer_block.dart';

class ProverbQuestionPage extends ConsumerStatefulWidget {
  const ProverbQuestionPage({super.key, required this.questionNum});
  final int questionNum;

  @override
  ConsumerState<ProverbQuestionPage> createState() =>
      ProverbQuestionPageState();
}

class ProverbQuestionPageState extends ConsumerState<ProverbQuestionPage> {
  String answerSentence = '';
  @override
  Widget build(BuildContext context) {
    int questionNum = widget.questionNum;
    final questionData = ref.watch(questionDataProvider)[questionNum];

    final notifier = ref.read(questionDataProvider.notifier);
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                Text('${questionData.question}'),
                const SizedBox(height: 15),
                TextField(
                  autocorrect: false,
                  maxLines: null,
                  autofocus: true,
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
                    onPressed: () {
                      notifier.addAnswerAndScore(questionNum, answerSentence);
                      ref.read(isAnsweredProvider.notifier).state = true;
                    },
                    child: const Text('答え合わせ')),
                    const SizedBox(height: 15), 
                    const Divider(),
                Container(
                  height: 200,
                  width: 500,
                  child: Center(
                      child: ref.watch(isAnsweredProvider)
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ModifiedAnswerRichText(page: questionNum),
                              SizedBox(height: 20,),
                                Text(
                                    '間違い:${questionData.wrongWordsCount.toString()}')
                              ],
                            )
                          : Container()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
