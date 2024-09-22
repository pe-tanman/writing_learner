import 'package:flutter/material.dart';
import 'package:writing_learner/provider/database_helper.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/screens/review_question_view.dart';
import 'package:writing_learner/themes/app_color.dart';

class QuestionListScreen extends StatefulWidget {
  static const routeName = 'question-list-screen';

  const QuestionListScreen({super.key});
  @override
  _QuestionListScreenState createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  QuestionDatabaseHelper dbHelper = QuestionDatabaseHelper();

  var questionList = [];
  var isLoading = true;
  var isInit = true;
  final materialId = 2;

  Future<void> questions() async {
    var questionMaps = await dbHelper.getQuestionData(materialId);
    List<Map<String, dynamic>> result = [];
    if (questionMaps.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    for (var element in questionMaps) {
      result.add({
        'sentence': element['question_sentence'],
        'accuracy_rate': element['accuracy_rate'].toString(),
        'error_tag': 'error_types_str',
      });
    }
    questionList = result;
    setState(() {
      isLoading = false;
      print(questionList);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      questions();
      isInit = false;
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : (questionList.isEmpty)
                ? const Center(child: Text('復習する問題がありません'))
                : Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.themeColor),
                          onPressed: () => Navigator.of(context)
                              .pushNamed(ReviewQuestionView.routeName),
                          child: const SizedBox(
                              child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 60),
                            child: Text(
                              '復習を始める',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ))),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: questionList.length,
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.grey,
                          ),
                          itemBuilder: (context, index) {
                            final review = questionList[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                    backgroundColor: AppColors.themeColor,
                                    radius: 25,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                          '${questionList[index]['accuracy_rate']}%',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    )),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(questionList[index]['sentence']!),
                                    const SizedBox(height: 10),
                                    Text(
                                        '#${questionList[index]['error_tag']!}',
                                        style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
