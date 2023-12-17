import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:vyperto/view-model/account_provider.dart';
import 'views/page_controller.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/api/profile_api.dart';
import 'package:vyperto/model/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeUser();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ReservationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AccountProvider(),
        ),
      ],
      child: MaterialApp(
        home: Page_Controller(), // This widget should expect two databases
      ),
    ),
  );
}

Future<void> initializeUser() async {
  try {
    // Initialization logic here
    Profile profile = Profile(
      meno: 'Marko',
      priezvisko: 'Mrkvicka',
      email: 'janko@example.com',
      zostatok: 1000,
      body: 15,
      miesto: 'Koleje pod Palackého vrchem',
      darkMode: 0,
    );

    ProfileAPI _profileAPI = ProfileAPI();
    await _profileAPI.insertProfile(profile);
  } catch (error) {
    // Handle errors appropriately
    print('Initialization error: $error');
  }
}
