import 'package:flutter/material.dart';
import 'package:writing_learner/screens/constact_screen.dart';
import 'package:writing_learner/screens/privacy_policy.dart';
import 'package:writing_learner/themes/app_theme.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Text("メニュー", style: appTheme().textTheme.headlineMedium),
          SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('フィードバックを送信'),
            onTap: () {
              _sendFeedback(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('プライバシーポリシー'),
            onTap: () {
              _checkTermsAndPolicies(context);
            },
          ),
        ],
      ),
    );
  }

  void _checkTermsAndPolicies(BuildContext context) {
    // Navigate to the Terms and Policies screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PolicyScreen()),
    );
  }

  void _sendFeedback(BuildContext context) {
    // Navigate to the Send Feedback screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactScreen()),
    );
  }
}


