import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/screens/home_screen.dart';
import 'package:writing_learner/screens/record_screen.dart';
import 'package:writing_learner/screens/review_list_screen.dart';
import 'package:writing_learner/screens/menu_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const routeName = 'main-screen';
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool isLoading = false;
  var screens = [
    const HomeScreen(),
    const ReviewListScreen(),
     ProgressRecordScreen(),
    const MenuScreen(),
  ];
  var _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(index);
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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: screens[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
           currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: '復習'),
            BottomNavigationBarItem(icon: Icon(Icons.equalizer), label: '記録'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'メニュー'),
          ],
          type: BottomNavigationBarType.fixed,
        ));
  }
}
