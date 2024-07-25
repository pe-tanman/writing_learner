import 'package:flutter/material.dart';
import 'package:writing_learner/screens/question_start_screen.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/widgets/modify_answer_block.dart';

class ProverbQuestionView extends ConsumerStatefulWidget {
  const ProverbQuestionView({super.key});
  static const routeName = 'proverb-question-view';
  @override
  ConsumerState<ProverbQuestionView> createState() =>
      ProverbQuestionViewState();
}

class ProverbQuestionViewState extends ConsumerState<ProverbQuestionView> {
  var isInit = true;
  var isLoading = true;
  var answered = false;
  int currentPage = 0;

  List<Widget> availableQuestionPages = [];

  // Import a csv flie
  Future<List<List<String>>> loadCSVFromAssets() async {
    String assetPath = 'lib/assets/japanese_proverbs.csv';
    final String csvString = await rootBundle.loadString(assetPath);
    List<List<String>> csvData =
        csvString.split('\n').map((line) => line.split(',')).toList();
    return csvData;
  }

  Future<void> initPages(WidgetRef ref) async {
    availableQuestionPages.add(const QuestionStartScreen());
    await preloadNextPage(ref, 0);
    isInit = false;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> preloadNextPage(WidgetRef ref, int nextPage) async {
    var csvData = await loadCSVFromAssets();
    String questionSentence = csvData[nextPage][0];
    String modifiedSentence = csvData[nextPage][1];
    QuestionData questionData = QuestionData(
        question: questionSentence,
        answer: '',
        modified: modifiedSentence,
        correctWordsCount: 0);
    ref.read(questionNotifierProvider.notifier).addQuestionData(questionData);
    availableQuestionPages.add(questionPage(ref, nextPage));
  }

  var answerSentence = '';

//TODOクラスに分けないとansweredが変更されたときに回答が表示できない
  Widget questionPage(WidgetRef ref, int page) {
    final questionData = ref.watch(questionNotifierProvider)[page];
    final notifier = ref.read(questionNotifierProvider.notifier);
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
              ElevatedButton(onPressed: (){
                notifier.addAnswerAndScore(currentPage, answerSentence);
                  setState(() {
                    answered = true;
                  });
                  print('detect');
              }, child: Text('答え合わせ')),

                Container(
                  height: 200,
                  width: 500,
                  color: Colors.grey,
                  child: Center(
                      child: answered
                          ? Column(
                              children: [
                                ModifiedAnswerRichText(page: page),
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

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      initPages(ref);
    }
    return Scaffold(
      appBar: AppBar(
        actions: [],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                children: [CircularProgressIndicator(), Text('あなたに最適な問題を作成中')],
              ),
            )
          : PageView(
              scrollDirection: Axis.horizontal,
              onPageChanged: (int page) async {
                currentPage = page - 1;
                await preloadNextPage(ref, currentPage + 1);
                answered = false;
              },
              children: availableQuestionPages,
            ),
    );
  }
}
