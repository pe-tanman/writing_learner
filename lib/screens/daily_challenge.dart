import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/screens/home_screen.dart';
import 'package:writing_learner/screens/question_page.dart';
import 'package:writing_learner/screens/question_start_screen.dart';
import 'package:writing_learner/screens/question_result_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/widgets/loading_indicator.dart';
import 'package:writing_learner/provider/database_helper.dart';
import 'dart:math' as math;

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});
  static const routeName = 'daily-challenge';
  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      DailyChallengeScreenState();
}

class DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  var isInit = true;
  var isLoading = true;
  var answered = false;
  int currentPage = 0;
  int questionNum = 0;
  late PageController _pageController;

  QuestionDatabaseHelper dbHelper = QuestionDatabaseHelper();
  MaterialDatabaseHelper materialDatabaseHelper = MaterialDatabaseHelper();

  List<Widget> availableQuestionPages = [];

  Future<void> initPages(WidgetRef ref, BuildContext context) async {
    availableQuestionPages.add(const QuestionStartScreen());
    await preloadNextPage(ref, questionNum, context);
    ref.read(isAnsweredProvider.notifier).state = true;
    isInit = false;
    print(ref.read(questionDataProvider));
    setState(() {
      isLoading = false;
    });
  }

  Future<void> preloadNextPage(
      WidgetRef ref, int nextQuestionNum, BuildContext context) async {
    var questionMaps = await dbHelper.getReviewData();
    var materialMaps = await materialDatabaseHelper.getAllData();
    var questionMap = {};
    String questionSentence = '';
    int currentMaterialId = 0;
    int questionNumInCurrentSession = nextQuestionNum % 3;
    if (questionMaps.length <= questionNum) {
      if (questionMaps.isEmpty) {
        questionMap = questionMaps[questionNum];
        var random = math.Random();
        currentMaterialId = random.nextInt(materialMaps.length - 1);
        var randomQuestions = await dbHelper.getRandomData();
        questionSentence = randomQuestions[0]['question_sentence'];
      }
      availableQuestionPages.add(QuestionResultScreen(null, nextQuestionNum,
          nextQuestionNum - questionNumInCurrentSession, nextQuestionNum, true));
      return;
    } else {
      questionMap = questionMaps[questionNum];
      questionSentence = questionMap['question_sentence'];
      currentMaterialId = questionMap['material_id'];
    }

    ref
        .read(questionDataProvider.notifier)
        .addQuestionSentence(currentMaterialId, questionSentence);
        print('nextQuestionNum$nextQuestionNum');
    availableQuestionPages.add(QuestionPage(questionNum: nextQuestionNum));
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
      initPages(ref, context);
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
                        !ref.watch(isAnsweredProvider)|| currentPage == 4) {
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
                          null, 0, 0, 2, true));
                    } else {
                      await preloadNextPage(ref, questionNum, context);
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
