import 'package:flutter/material.dart';
import 'package:writing_learner/screens/question_start_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/utilities/generative_content.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/widgets/modify_answer_block.dart';


class QuestionView extends ConsumerStatefulWidget {
  const QuestionView({super.key});
  static const routeName = 'question-view';
  @override
  ConsumerState<QuestionView> createState() => QuestionViewState();
}

class QuestionViewState extends ConsumerState<QuestionView> {
  List<Widget> questionPages = [const QuestionStartScreen()];
  var isInit = true;
  var isLoading = true;
  var answered = false;
  int currentPage = 0;

  List<Widget> availableQuestionPages = [];

  Future<void> initPages(WidgetRef ref) async {
    availableQuestionPages.add(const QuestionStartScreen());
    await preloadNextPage(ref, 0);
    isInit = false;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> preloadNextPage(WidgetRef ref, int nextPage) async {
    String questionSentence = await GenerativeService()
        .generateText('大学入試対策になるような英訳問題の和文をランダムに出力して。ただし問題の和文のみ一文を出力すること。');
    ref.read(questionDataProvider.notifier).addQuestionSentence(questionSentence);
    availableQuestionPages.add(questionPage(ref, nextPage));
  }

  var answerSentence = '';

  Widget questionPage(WidgetRef ref, int page) {
    final questionData = ref.watch(questionDataProvider)[page];
    final notifier = ref.read(questionDataProvider.notifier);
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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: (detail) {
                  answered = true;
                  notifier.addAnswer(page, answerSentence);
                },
                child: Container(
                  height: 200,
                  width: 500,
                  color: Colors.grey,
                  child: Center(
                      child: Column(
                    children: [if (answered) ModifiedAnswerRichText(page: page), if (answered) Text('正解語数 :${questionData.correctWordsCount.toString()}')],
                  )),
                ),
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
