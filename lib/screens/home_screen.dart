import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/screens/filling_pattern_question_view.dart';
import 'package:writing_learner/screens/filling_question_view.dart';
import 'package:writing_learner/screens/w2p_question_view.dart';
import 'package:writing_learner/themes/app_color.dart';
import 'package:writing_learner/screens/question_view.dart';
import 'package:writing_learner/screens/proverb_question_view.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/themes/app_theme.dart';

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
          title: SizedBox(height:70, child:  Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset('lib/assets/wridge.png'),
          )),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
           const SizedBox(height: 20),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Row(
                  children: [
                    Text(
                      'デイリーチャレンジ',
                      style: appTheme().textTheme.headlineMedium,
                    ),
                    const Icon(Icons.arrow_right_alt)
                  ],
                             ),
               ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 200,
                  width: 400,
                  decoration: BoxDecoration(
                    color: AppColors.themeColor,
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(image:  AssetImage('lib/assets/coming_wide.png'), fit: BoxFit.fill),
                  ),
                ),
              ),
              const SizedBox(height: 20),
               Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      '最近学習した教材',
                      style: appTheme().textTheme.headlineMedium,
                    ),
                    const Icon(Icons.arrow_right_alt)
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildItem('AI最難関英訳', '和文英訳', 'lib/assets/blue.png',
                        QuestionView.routeName, context, ref, 'Tokyo'),
                        _buildItem(
                        'Write to the point',
                        '英訳教材',
                        'lib/assets/blue.png',
                        W2pQuestionView.routeName,
                        context,
                        ref),
                    _buildItem('AI最難関穴埋め', '和文英訳', 'lib/assets/coming_square.png',
                        FillingQuestionView.routeName, context, ref, 'Tokyo'),
                    
                    _buildItem('ことわざ', '表現', 'lib/assets/coming_square.png',
                        ProverbQuestionView.routeName, context, ref),
                  ],
                ),
              ),
            ],
          ),
                ),
        ),
    );
  }
  Widget _buildItem(String title, String discription, var imagePath, var route,
      var context, WidgetRef ref,
      [String? levelStr]) {
    return SizedBox(
      width: 180,
      height: 240,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () {
            if (levelStr == null) {
              Navigator.of(context).pushNamed(route);
            } else {
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 144,
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
                          color: AppColors.lightText1,
                        ),
                      ),
                      Text(
                        discription,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightText1,
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

