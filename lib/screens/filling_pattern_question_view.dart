import 'package:flutter/material.dart';
import 'package:writing_learner/screens/filling_question_page.dart';
import 'package:writing_learner/screens/question_result_screen.dart';
import 'package:writing_learner/screens/question_start_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/utilities/generative_content.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'dart:math';

class FillingPatternQuestionView extends ConsumerStatefulWidget {
  const FillingPatternQuestionView({super.key});
  static const routeName = 'filling-pattern-question-view';

  @override
  ConsumerState<FillingPatternQuestionView> createState() =>
      FillingPatternQuestionViewState();
}

class FillingPatternQuestionViewState
    extends ConsumerState<FillingPatternQuestionView> {
  var isInit = true;
  var isLoading = true;
  var answered = false;
  int currentPage = 0;
  int questionNum = -1;
  late PageController _pageController;

  List<Widget> availableQuestionPages = [];

  Future<void> initPages(WidgetRef ref) async {
    availableQuestionPages.add(const QuestionStartScreen());
    await preloadNextPage(ref, 0);
    ref.read(isAnsweredProvider.notifier).state = true;
    isInit = false;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> preloadNextPage(WidgetRef ref, int nextQuestion) async {
    String levelStr = ModalRoute.of(context)!.settings.arguments as String;

    final patternData = extractPatternData();
    String questionSentence = await GenerativeService().generateText(
        '$patternDataを使って$levelStr大学入試対策になるような英訳問題の和文をランダムに出力して。ただし問題の和文のみ一文を出力すること。');
    String fillQuestionSentence = await GenerativeService().generateText(
        "以下の文章を英訳して、英語学習上重要な$patternDataに対応する部分と他のいくつかの文構造や単語の部分を___を用いて穴埋め形式にして。ただし穴埋め形式の文のみ出力しなさい。：$questionSentence");


    ref.read(questionDataProvider.notifier).addQuestionData(QuestionData(
        question: questionSentence,
        answer: '',
        wrongWordsCount: 0,
        modified: '',
        fillingQuestion: fillQuestionSentence));
    print(questionNum);
    availableQuestionPages.add(FillingQuestionPage(questionNum: nextQuestion));
  }

  Future<String> extractPatternData() async {
    try {
      // Load the JSON file
      String jsonString =
          await rootBundle.loadString('lib/assets/pattern_data.json');

      // Parse the JSON string into a List of Strings
      List<dynamic> jsonData = jsonDecode(jsonString);

      // Extract the pattern data from the JSON
      List<String> patternData =
          jsonData.map((data) => data['pattern'] as String).toList();
      print(patternData);
      // Randomly select one pattern from patternData
      final random = Random();
      final selectedPattern = patternData[random.nextInt(patternData.length)];

      return selectedPattern;
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }

  var answerSentence = '';
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
                  children: [
                    CircularProgressIndicator(),
                    Text('あなたに最適な問題を作成中')
                  ],
                ),
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollUpdateNotification &&
                      notification.metrics is PageMetrics) {
                    PageMetrics metrics = notification.metrics as PageMetrics;
                    int nextPage = metrics.page!.round();
                    if (nextPage > currentPage &&
                        ref.watch(isAnsweredProvider)) {
                    } else if (metrics.page! < currentPage.toDouble()) {
                      _pageController.jumpToPage(currentPage);
                      print('back');
                      return true;
                    } else if (metrics.page! > currentPage.toDouble() &&
                        !ref.watch(isAnsweredProvider)) {
                      _pageController.jumpToPage(currentPage);
                      print('prohibited');
                      return true;
                    }
                  }
                  return false;
                },
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  onPageChanged: (int page) async {
                    if (page % 6 != 0) {
                      questionNum++;
                    }

                    if ((page + 1) % 6 == 0) {
                      availableQuestionPages.add(const QuestionResultScreen());
                    } else {
                      await preloadNextPage(ref, questionNum + 1);
                    }

                    if ((page) % 6 == 0) {
                      ref.read(isAnsweredProvider.notifier).state = true;
                    } else {
                      ref.read(isAnsweredProvider.notifier).state = false;
                    }

                    currentPage = page;
                  },
                  children: availableQuestionPages,
                ),
              ));
  }
}
