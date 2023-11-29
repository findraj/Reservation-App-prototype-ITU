import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/page_controller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/api/reservation_api.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/api/profile_api.dart';
import 'package:vyperto/model/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Database reservationDatabase = await initializeReservationDB();
  Database profileDatabase = await initializeProfileDB();

  // Kedze nebudeme implementovat registraciu uzivatelov, tak si vytvorime profil uzivatela
  Profile profile = Profile();
  profile.meno = 'Janko Fero';
  profile.email = 'janko@exampel.com';
  profile.zostatok = 1000;

  await insertProfile(profile, profileDatabase);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ReservationProvider(reservationDatabase),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(profileDatabase),
        ),
      ],
      child: MaterialApp(
        home: Page_Controller(reservationDatabase, profileDatabase), // This widget should expect two databases
      ),
    ),
  );
}
