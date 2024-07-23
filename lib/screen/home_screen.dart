import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:writing_learner/themes/app_color.dart';
import 'package:writing_learner/screen/question_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final routeName = 'home-screen';
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String levelStr = "難関国立";
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

class HorizontalContents extends StatelessWidget {
  const HorizontalContents({super.key});

  @override
  Widget build(BuildContext context) {
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
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildItem('AI旧帝大', '和文英訳',
                     'lib/assets/ai_image.jpeg', context),
                _buildItem('ことわざ', '表現',
                    'lib/assets/ai_image.jpeg', context),
               _buildItem('構文150', '構文',
                    'lib/assets/ai_image.jpeg', context),
              ]),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String discription, var imagePath, var context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(QuestionView.routeName);
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
