import 'package:flutter/material.dart';
import 'package:writing_learner/themes/app_color.dart';

class QuestionStartScreen extends StatefulWidget {
  static const routeName = '/question-start-screen';
  @override
  QuestionStartScreenState createState() => QuestionStartScreenState();
}

class QuestionStartScreenState extends State<QuestionStartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    // アニメーションを2秒間で行い、スワイプの動作を強調
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);

    // 左方向に大きくスワイプさせる
    _offsetAnimation = Tween<Offset>(
      begin: Offset(1.5, 0), // 画面外右からスタート
      end: Offset(-1.5, 0), // 左方向へ大きくスワイプ
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SlideTransition(
          position: _offsetAnimation,
          child: Icon(
            Icons.circle,
            size: 50,
            color: AppColors.themeColor,
          ),
        ),
        SizedBox(height: 10),
        Text('スワイプしてください', style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
