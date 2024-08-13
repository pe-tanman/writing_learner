import 'package:flutter/material.dart';
import 'package:writing_learner/screens/filling_pattern_question_view.dart';
import 'package:writing_learner/screens/home_screen.dart';
import 'package:writing_learner/screens/question_view.dart';
import 'package:writing_learner/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/screens/proverb_question_view.dart';
import 'package:writing_learner/screens/filling_question_view.dart';

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
        home: const HomeScreen(),
        routes: {
          HomeScreen.routeName: (ctx) => const HomeScreen(),
          QuestionView.routeName: (ctx) =>  const QuestionView(),
          FillingQuestionView.routeName: (ctx) => const FillingQuestionView(),
          ProverbQuestionView.routeName: (ctx) => const ProverbQuestionView(),
          FillingPatternQuestionView.routeName: (ctx) => const FillingPatternQuestionView(),
        });
  }
}
