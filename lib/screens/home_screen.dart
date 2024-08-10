import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/screens/filling_pattern_question_view.dart';
import 'package:writing_learner/screens/filling_question_view.dart';
import 'package:writing_learner/themes/app_color.dart';
import 'package:writing_learner/screens/question_view.dart';
import 'package:writing_learner/screens/proverb_question_view.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/provider/question_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home-screen';
  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  String questionSentence = '';
  var answerSentence = '';
  var modifiedSentence = '';

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('\nホーム'),
        ),
        body: const Column(
          children: [HorizontalContents()],
        ));
  }
}

class HorizontalContents extends ConsumerWidget {
  const HorizontalContents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '最近学習した教材',
                  style: TextStyle(fontSize: 20),
                ),
                Icon(Icons.arrow_right_alt)
              ],
            ),
          ),
             SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                _buildItem('AI東大英訳', '和文英訳', 'lib/assets/ai_image.jpeg',
                  QuestionView.routeName, context, ref, '東京'),
                _buildItem('AI東大穴埋め', '和文英訳', 'lib/assets/ai_image.jpeg',
                  FillingQuestionView.routeName, context, ref, '東京'),
                _buildItem('ことわざ', '表現', 'lib/assets/ai_image.jpeg',
                  ProverbQuestionView.routeName, context, ref),
                _buildItem('構文150', '構文', 'lib/assets/ai_image.jpeg',
                  FillingPatternQuestionView.routeName, context, ref),
                ],
              ),
              ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String discription, var imagePath, var route,
      var context, WidgetRef ref, [String? levelStr]) {
    return SizedBox(
      width: 150,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () {
            if(levelStr == null){
              Navigator.of(context).pushNamed(route);
            }
            else{
              Navigator.of(context).pushNamed(route, arguments: levelStr);
            }
            
            ref.read(questionDataProvider.notifier).clearQuestions();
            ref.read(isAnsweredProvider.notifier).state = true;
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.themeColor),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 119,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        discription,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
