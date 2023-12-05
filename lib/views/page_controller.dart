import 'package:flutter/material.dart';
import 'package:vyperto/assets/colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:provider/provider.dart';
import 'profile_route.dart';
import 'home_screen.dart';
import 'casovac_screen.dart';
import 'rezervacia_screen.dart';
import 'odmeny_screen.dart';

class Page_Controller extends StatefulWidget {
  final Database reservationDatabase;
  final Database profileDatabase;

  Page_Controller(this.reservationDatabase, this.profileDatabase);

  @override
  _Page_ControllerState createState() => _Page_ControllerState();
}

class _Page_ControllerState extends State<Page_Controller> {
  int _currentIndex = 0; // Index of the currently selected tab

  List<Widget> _tabs = [];

  final List<String> _tabTitles = [
    'Domov',
    'Rezervácia',
    'Časovač',
    'Odmeny',
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Since we are using Providers to handle databases, no need to pass databases to widgets.
    _tabs = [
      HomeScreen(),
      const RezervaciaScreen(),
      const CasovacScreen(),
      const OdmenyScreen(),
    ];

    // Since ReservationProvider is initialized at the start, we fetch reservations here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationProvider>().fetchReservations();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Provider.of or context.watch to get the Database instance if needed
    // Example: Database db = Provider.of<ReservationProvider>(context).database;

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
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: 'Odmeny',
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
