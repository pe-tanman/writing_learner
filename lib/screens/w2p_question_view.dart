import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/screens/question_page.dart';
import 'package:writing_learner/screens/question_start_screen.dart';
import 'package:writing_learner/screens/question_result_screen.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;
import 'package:writing_learner/widgets/loading_indicator.dart';
import 'package:writing_learner/provider/database_helper.dart';

class W2pQuestionView extends ConsumerStatefulWidget {
  const W2pQuestionView({super.key});
  static const routeName = 'w2p-question-view';
  @override
  ConsumerState<W2pQuestionView> createState() => W2pQuestionViewState();
}

class W2pQuestionViewState extends ConsumerState<W2pQuestionView> {
  var isInit = true;
  var isLoading = true;
  var answered = false;
  int currentPage = 0;
  int questionNum = -1;
  int materialId = 2;
  late PageController _pageController;
  int startQuestionId = 0;

  QuestionDatabaseHelper dbHelper = QuestionDatabaseHelper();
  MaterialDatabaseHelper materialDatabaseHelper = MaterialDatabaseHelper();

  List<Widget> availableQuestionPages = [];

  Future<void> initPages(WidgetRef ref) async {
    availableQuestionPages.add(const QuestionStartScreen());
    startQuestionId = await getNextId();
    print("startQuestionId$startQuestionId");
    await preloadNextPage(ref, questionNum + 1);
    ref.read(isAnsweredProvider.notifier).state = true;
    isInit = false;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> preloadNextPage(WidgetRef ref, int nextQuestionNum) async {
    var questionMap = await dbHelper.getSelectedData(
        materialId,
        startQuestionId +
            nextQuestionNum); //current Question id = nextQuestionId + nextQuestionNum
    print("map$questionMap");
    String questionSentence = '';
    int questionNumInCurrentSession = (nextQuestionNum-1) % 3;
    
    if (questionMap.isEmpty) {
      availableQuestionPages.add(QuestionResultScreen(materialId, startQuestionId+nextQuestionNum, nextQuestionNum-questionNumInCurrentSession, nextQuestionNum, false));
      return;
    } else {
      questionSentence = questionMap[0]['question_sentence'];
    }

    ref
        .read(questionDataProvider.notifier)
        .addQuestionSentence(materialId, questionSentence);
    availableQuestionPages.add(QuestionPage(questionNum: nextQuestionNum));
  }

  var answerSentence = '';
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  Future<int> getNextId() async {
    return await materialDatabaseHelper.getNextNum(materialId);
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      initPages(ref);
    }

    return Scaffold(
        appBar: AppBar(
          actions: const [],
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
                    if (page % 4 != 0) {
                      questionNum++;
                    }

                    if ((page + 1) % 4 == 0) {
                      availableQuestionPages.add(QuestionResultScreen(
                          materialId,
                          startQuestionId,
                          questionNum - 2,
                          questionNum, false));
                          print('startQuestionNum${questionNum-2}');
                          print('endQuestionNum$questionNum');
                    } else {
                      await preloadNextPage(ref,
                          questionNum + 1); 
                    }

                    if ((page) % 4 == 0) {
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
