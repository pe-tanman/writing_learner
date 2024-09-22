import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:writing_learner/themes/app_color.dart';

class ContactScreen extends StatefulWidget {
  static const routeName = "/contact-screen";

  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool _pageIsLoading = true;

  @override
  Widget build(BuildContext context) {
     final controller = WebViewController()
      ..loadRequest(Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSeuC9lzVCWdQvSQ6Tf9lmim_jHBRAotOvBqM-1QfWY5Q1vnVA/viewform?usp=sf_link'))
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
      
      appBar: AppBar(title: const Text("お問い合わせ")),
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
