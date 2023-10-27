import 'package:flutter/material.dart';
import 'profile_route.dart';
import 'home_screen.dart';
import 'colors.dart';
import 'casovac_screen.dart';
import 'rezervacia_screen.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0; // Index of the currently selected tab

  final List<Widget> _tabs = [
    HomeScreen(),
    const RezervaciaScreen(),
    const CasovacScreen(),
  ];

  final List<String> _tabTitles = [
    'Domov',
    'Rezervácia',
    'Časovač',
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        title: Text(
          _tabTitles[_currentIndex],
          style: const TextStyle(
            color: appBarIconColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileRoute()),
              );
            },
            icon: const Icon(
              Icons.account_circle,
              color: appBarIconColor,
              size: 30.0,
            ),
          ),
        ],
      ),
      body: PageView(
        onPageChanged: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        controller: _pageController,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: boxDecoration,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });

            _pageController.animateToPage(
              newIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Domov',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Rezervácia',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: 'Časovač',
            ),
          ],
          type: BottomNavigationBarType.shifting,
          backgroundColor: appBarIconColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          selectedFontSize: selectedFontSize,
          selectedIconTheme: const IconThemeData(size: 30),
          unselectedIconTheme: const IconThemeData(size: 20),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: selectedLabelStyle,
          unselectedLabelStyle: unselectedLabelStyle,
          elevation: _currentIndex == 0 ? 2 : 0,
        ),
      ),
    );
  }
}

const BoxDecoration boxDecoration = BoxDecoration(
  boxShadow: <BoxShadow>[
    BoxShadow(
      color: Color.fromARGB(93, 0, 0, 0),
      blurRadius: 10,
    ),
  ],
);
