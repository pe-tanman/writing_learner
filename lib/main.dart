
import 'package:flutter/material.dart';
import 'package:writing_learner/screen/home_screen.dart';
import 'package:writing_learner/screen/question_screen.dart';
import 'package:writing_learner/screen/question_view.dart';
import 'package:writing_learner/themes/app_theme.dart';


void main() {
  runApp(const MyApp());
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
      routes:{
        HomeScreen.routeName: (ctx) => const HomeScreen(),
        QuestionView.routeName: (ctx) => const QuestionView(),
      }
    );
  }
}
