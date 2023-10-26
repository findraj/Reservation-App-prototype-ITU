import 'package:flutter/material.dart';

// Custom Colors
const Color primaryColor = Color.fromARGB(255, 245, 251, 255);
const Color appBarBackgroundColor = Colors.white;
const Color appBarIconColor = Colors.black;
const selectedItemColor = Colors.blue;
const unselectedItemColor = Colors.black;
const selectedFontSize = 16.0;
const TextStyle selectedLabelStyle = TextStyle(fontWeight: FontWeight.bold);
const TextStyle unselectedLabelStyle = TextStyle(fontWeight: FontWeight.normal);


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
    const HomeScreen(),
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

final BoxDecoration boxDecoration = const BoxDecoration(
  boxShadow: <BoxShadow>[
    BoxShadow(
      color: Colors.black,
      blurRadius: 10,
    ),
  ],
);


class ProfileRoute extends StatelessWidget {
  const ProfileRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: appBarBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        title: const Text(
          "Profil",
          style: TextStyle(
            color: appBarIconColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle profile button action
            },
            icon: const Icon(
              Icons.account_circle,
              color: appBarIconColor,
              size: 30.0,
            ),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Domov'),
    );
  }
}

class RezervaciaScreen extends StatelessWidget {
  const RezervaciaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Rezervacia'),
    );
  }
}

class CasovacScreen extends StatelessWidget {
  const CasovacScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Casovac'),
    );
  }
}