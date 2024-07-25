import 'package:flutter/material.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/screens/proverb_question_page.dart';
import 'package:writing_learner/screens/question_start_screen.dart';

import 'package:flutter/services.dart' show rootBundle;

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
    ref.read(questionDataProvider.notifier).addQuestionData(questionData);
    availableQuestionPages.add(ProverbQuestionPage(page:nextPage));
  }

  var answerSentence = '';


  @override
  Widget build(BuildContext context) {
     answered = ref.watch(isAnsweredProvider);
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
                ref.read(isAnsweredProvider.notifier).state = false;
              },
              children: availableQuestionPages,
            ),
    );
  }
}
