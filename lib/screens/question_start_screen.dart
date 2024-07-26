import 'package:flutter/material.dart';

class QuestionStartScreen extends StatelessWidget {
  const QuestionStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return const Scaffold(
        body: Column(
      children: [Text('右スワイプで次の問題へ')],
    ));
  }
}
