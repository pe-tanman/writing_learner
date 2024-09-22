import 'package:flutter/material.dart';
import 'package:writing_learner/screens/constact_screen.dart';
import 'package:writing_learner/screens/daily_challenge.dart';
import 'package:writing_learner/screens/home_screen.dart';
import 'package:writing_learner/screens/main_screen.dart';
import 'package:writing_learner/screens/privacy_policy.dart';
import 'package:writing_learner/screens/question_view.dart';
import 'package:writing_learner/screens/review_question_view.dart';
import 'package:writing_learner/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/screens/proverb_question_view.dart';
import 'package:writing_learner/screens/filling_question_view.dart';
import 'package:writing_learner/screens/w2p_question_view.dart';
import 'package:writing_learner/screens/review_list_screen.dart';

void main() {
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Writing learner',
        theme: appTheme(),
        home: const MainScreen(),
        routes: {
          HomeScreen.routeName: (ctx) => const HomeScreen(),
          QuestionView.routeName: (ctx) =>  const QuestionView(),
          FillingQuestionView.routeName: (ctx) => const FillingQuestionView(),
          ProverbQuestionView.routeName: (ctx) => const ProverbQuestionView(),
          W2pQuestionView.routeName: (ctx) => const W2pQuestionView(),
          ReviewQuestionView.routeName: (ctx) => const ReviewQuestionView(),
          ReviewListScreen.routeName: (ctx) =>  ReviewListScreen(),
          DailyChallengeScreen.routeName: (ctx) => const DailyChallengeScreen(),
          MainScreen.routeName: (ctx) => const MainScreen(),
          ContactScreen.routeName: (ctx) => const ContactScreen(),
          PolicyScreen.routeName: (ctx) => const PolicyScreen(),
          /*FillingPatternQuestionView.routeName: (ctx) => const FillingPatternQuestionView(),*/
        });
  }
}
