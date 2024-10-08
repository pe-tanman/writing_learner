import 'package:flutter/material.dart';
import 'package:writing_learner/screens/filling_question_page.dart';
import 'package:writing_learner/screens/question_result_screen.dart';
import 'package:writing_learner/screens/question_start_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/utilities/generative_content.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/widgets/loading_indicator.dart';

class FillingQuestionView extends ConsumerStatefulWidget {
  const FillingQuestionView({super.key});
  static const routeName = 'filling-question-view';

  @override
  ConsumerState<FillingQuestionView> createState() =>
      FillingQuestionViewState();
}

class FillingQuestionViewState extends ConsumerState<FillingQuestionView> {
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
       Map fillQuestion =
        await GenerativeService().generateFillingQuestion();

    ref.read(questionDataProvider.notifier).addQuestionData(QuestionData(
          question: fillQuestion['Japanese Sentence'],
          answer: '',
          wrongWordsCount: 0,
          modified: fillQuestion['English Sentence'],
          fillingQuestion: fillQuestion['Filling Question'],
        ));
    availableQuestionPages.add(FillingQuestionPage(questionNum: nextQuestion));
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
