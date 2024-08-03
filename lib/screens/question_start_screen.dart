import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/question_provider.dart';

class QuestionStartScreen extends ConsumerStatefulWidget {
  const QuestionStartScreen({super.key});

  @override
  ConsumerState<QuestionStartScreen> createState() => _QuestionStartScreenState();
}

class _QuestionStartScreenState extends ConsumerState<QuestionStartScreen> {
  

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body:  Column(
      children: [
        Text('右スワイプで次の問題へ'),
      ],
    ));
  }
  
}
