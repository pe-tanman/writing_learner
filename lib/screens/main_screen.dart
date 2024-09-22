import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/screens/home_screen.dart';
import 'package:writing_learner/screens/review_list_screen.dart';
import 'package:writing_learner/screens/menu_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  static const routeName = 'main-screen';
  @override
  ConsumerState<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  bool isLoading = false;
  var screens = [
    const HomeScreen(),
    const ReviewListScreen(),
    const MenuScreen(),
  ];
  var index = 0;
   void _onItemTapped(int index) {
    setState(() {
      index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Image.asset('lib/assets/wridge.png'),
              )),
        ),
        body: screens[index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
            BottomNavigationBarItem(
                icon: Icon(Icons.equalizer), label: '記録'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'メニュー'),
          ],
          type: BottomNavigationBarType.fixed,
        ));
  }
}
