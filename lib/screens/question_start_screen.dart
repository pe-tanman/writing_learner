import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/themes/app_color.dart';

class QuestionStartScreen extends ConsumerStatefulWidget {
  const QuestionStartScreen({super.key});

  @override
  ConsumerState<QuestionStartScreen> createState() =>
      _QuestionStartScreenState();
}

class _QuestionStartScreenState extends ConsumerState<QuestionStartScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swipe_left,
            color: AppColors.themeColor,
            size: 100,
          ),
        ],
      ),
    ));
  }
}
