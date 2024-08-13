import 'package:flutter/material.dart';
import 'package:writing_learner/themes/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'あなたに最適な問題を作成中',
            style: appTheme().textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}