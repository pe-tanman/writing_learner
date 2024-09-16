import 'package:flutter/material.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/screens/question_page.dart';
import 'package:writing_learner/screens/question_start_screen.dart';
import 'package:writing_learner/screens/question_result_screen.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;
import 'package:writing_learner/widgets/loading_indicator.dart';

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
  int questionNum = -1;
  int materialId = 4;
  int startQuestionId = 0;
  late PageController _pageController;

  List<Widget> availableQuestionPages = [];

  // Import a csv flie
  Future<List<List<String>>> loadCSVFromAssets() async {
    String assetPath = 'lib/assets/japanese_proverbs.csv';
    final String csvString = await rootBundle.loadString(assetPath);
    List<List<String>> csvData = fast_csv.parse(csvString);
    return csvData;
  }

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
    var csvData = await loadCSVFromAssets();
    String questionSentence = csvData[nextQuestion][0];
    String modifiedSentence = csvData[nextQuestion][1];
    QuestionData questionData = QuestionData(
        materialId: materialId,
        question: questionSentence,
        answer: '',
        modified: modifiedSentence,
        wrongWordsCount: 0,
        errors: []);

    ref.read(questionDataProvider.notifier).addQuestionData(questionData);
    availableQuestionPages.add(QuestionPage(questionNum: nextQuestion));
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
            ? LoadingIndicator()
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
                      return true;
                    } else if (metrics.page! > currentPage.toDouble() &&
                        !ref.watch(isAnsweredProvider)) {
                      _pageController.jumpToPage(currentPage);
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
                      availableQuestionPages.add(QuestionResultScreen(
                          materialId,
                          startQuestionId,
                          questionNum - 3,
                          questionNum));
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
