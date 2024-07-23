import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key, required this.question}) : super(key: key);
  static final routeName = 'question-screen';
  final String question;
  @override
  State<QuestionScreen> createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen> {
  late String questionSentence;
  var answerSentence = '';
  var modifiedSentence = '下スワイプで答え合わせ';

  bool isInit = true;
  bool isLoading = false;
  bool answered = false;

  int correct = 0;
  Future<String> generateText(String prompt) async {
    await dotenv.load(fileName: '.env');
    String apiKey = dotenv.get('GEMINI_API_KEY');

    final model =
        GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text!;
  }

  Future<void> showQuestionSentence() async {
    questionSentence = widget.question;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> modifyAnswer() async {
    setState(() {
      isLoading = true;
    });
    modifiedSentence = await generateText(
        '以下の文章(1)は大学入試の英訳問題(2)の回答である。問題の回答として適切になるように文法と自然な言語使用の観点から修正を加えて。ただし入力が正しい場合は文章(1)を、間違っている場合は修正後の一文のみ答えること。： (1)$answerSentence (2)$questionSentence');

    setState(() {
      isLoading = false;
      answered = true;
    });
  }

  Widget buildComparisonResult() {
    List<String> words1 = answerSentence.split(' ');
    List<String> words2 = modifiedSentence.split(' ');
    List<InlineSpan> spans = [];


    int i = 0, j = 0;
    while (i < words1.length || j < words2.length) {
      if (i < words1.length && j < words2.length && words1[i] == words2[j]) {
        spans.add(TextSpan(
            text: '${words2[j]} ',
            style: const TextStyle(
                fontSize: 15,
                decoration: TextDecoration.none,
                color: Colors.black)));
        i++;
        j++;
        correct++;
      } else {
        // Find the next matching word
        int nextMatch = _findNextMatch(words1, words2, i, j);
        if (nextMatch == -1) {
          // No more matches, add all remaining words with underline
          while (j < words2.length) {
            spans.add(TextSpan(
              text: '${words2[j]} ',
              style: const TextStyle(
                  fontSize: 15, decoration: TextDecoration.underline),
            ));
            j++;
          }
          break;
        } else {
          // Add words up to the next match with underline
          while (j < nextMatch) {
            spans.add(TextSpan(
              text: '${words2[j]} ',
              style: const TextStyle(
                  fontSize: 15, decoration: TextDecoration.underline),
            ));
            j++;
          }
          i = words1.indexOf(words2[nextMatch], i);
        }
      }
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }

  int _findNextMatch(
      List<String> words1, List<String> words2, int start1, int start2) {
    for (int i = start2; i < words2.length; i++) {
      if (words1.contains(words2[i])) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      showQuestionSentence();
    }
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
              Container(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text('問題文:\n$questionSentence'),
              ),
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
                  modifyAnswer();
                },
                child: Container(
                  height: 200,
                  width: 500,
                  color: Colors.grey,
                  child: Center(
                      child: Column(
                    children: [
                      buildComparisonResult(),
                      if (answered)
                      Text('正解語数 :${correct.toString()}')
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
