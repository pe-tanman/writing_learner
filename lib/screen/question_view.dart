import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:writing_learner/screen/question_screen.dart';
import 'package:writing_learner/screen/question_start_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class QuestionView extends StatefulWidget {
  const QuestionView({super.key});
  static const routeName = 'question-view';
  @override
  State<QuestionView> createState() => QuestionViewState();
}

class QuestionViewState extends State<QuestionView> {
  List<Widget> questionPages = [QuestionStartScreen()];
  var isInit = true;
  var isLoading = true;
  Future<String> generateText(String prompt) async {
    await dotenv.load(fileName: '.env');
    String apiKey = dotenv.get('GEMINI_API_KEY');

    final model =
        GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text!;
  }

  Future<void> preloadNextPage(int page) async {
    /*var japaneseSentences = [
      "近年、環境問題に対する意識が世界中で高まり、再生可能エネルギーの重要性が強調されています。",
      "古代の哲学者たちは、人間の存在意義について多くの議論を交わし、その影響は現代にも及んでいます。",
      "科学技術の進歩により、私たちの生活は劇的に変化し、医療や通信の分野で特に顕著です。",
      "文学作品を通じて異文化理解を深めることは、国際社会における重要な課題の一つです。",
      "歴史的な出来事の背景を理解することで、現代の社会問題をより深く洞察することが可能です。"
    ];*/

    for (int i = 0; i < 5; i++) {
      String questionSentence = await generateText(
          '大学入試対策になるような英訳問題の和文をランダムに出力して。ただし問題の和文のみ一文を出力すること。');

      questionPages.add(QuestionScreen(question: questionSentence));
    }
    questionPages.add(QuestionStartScreen());
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      preloadNextPage(1);
      isInit = false;
    }
    return Scaffold(
      appBar: AppBar(
        actions: [],
      ),
      body: isLoading
          ? Center(
              child: Column(
                children: [CircularProgressIndicator(), Text('あなたに最適な問題を作成中')],
              ),
            )
          : PageView(
              scrollDirection: Axis.horizontal,
              onPageChanged: (int page) {},
              children: questionPages,
            ),
    );
  }
}
