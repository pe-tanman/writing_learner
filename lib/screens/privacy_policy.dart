import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:writing_learner/themes/app_color.dart';

class PolicyScreen extends StatefulWidget {
  static const routeName = "/policy-screen";

  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => PolicyScreenState();
}

class PolicyScreenState extends State<PolicyScreen> {
  bool _pageIsLoading = true;

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..loadRequest(Uri.parse(
          'https://dogs-return-pi7.craft.me/p1xiONAb7AA1NM'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.google.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _pageIsLoading = false;
    return Scaffold(
      appBar: AppBar(title: const Text("プライバシーポリシー")),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller,
          ),
          if (_pageIsLoading)
            Container(
              height: double.infinity,
              width: double.infinity,
              color: AppColors.scaffoldBackgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
