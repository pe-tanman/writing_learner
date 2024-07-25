import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/widgets/modify_answer_block.dart';

class ProverbQuestionPage extends ConsumerStatefulWidget {
  const ProverbQuestionPage({super.key, required this.page});
  final int page;

  @override
  ConsumerState<ProverbQuestionPage> createState() =>
      ProverbQuestionPageState();
}

class ProverbQuestionPageState extends ConsumerState<ProverbQuestionPage> {
  String answerSentence = '';
  @override
  Widget build(BuildContext context) {
    int currentPage = widget.page;
    final answered = ref.read(isAnsweredProvider);
    final questionData = ref.watch(questionDataProvider)[currentPage];
    final notifier = ref.read(questionDataProvider.notifier);
    print('reloaded');
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
              Text('問題文:\n${questionData.question}'),
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
              ElevatedButton(
                  onPressed: () {
                    notifier.addAnswerAndScore(currentPage, answerSentence);
                    ref.read(isAnsweredProvider.notifier).state = true;
                    print('detect');
                  },
                  child: Text('答え合わせ')),
              Container(
                height: 200,
                width: 500,
                color: Colors.grey,
                child: Center(
                    child: ref.watch(isAnsweredProvider)
                        ? Column(
                            children: [
                              ModifiedAnswerRichText(page: currentPage),
                              Text(
                                  '正解語数 :${questionData.correctWordsCount.toString()}')
                            ],
                          )
                        : Container()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
