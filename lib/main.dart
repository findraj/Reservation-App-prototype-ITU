import 'package:flutter/material.dart';
import 'package:vyperto/components/reservation.dart';
import 'screens/pagecontroller.dart';
import 'package:vyperto/components/fetch_reservations.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Database database = await initializeDB();

  // Staticka rezervacia, ked uz tam raz je, tak ostava v DB, len aby sa nieco zobrazovalo,
  // ked nemame este vytvorenie rezervacie
  var res = Reservation(
    id: 1,
    machine: 'pracka',
    date: DateTime.now(),
    location: 'ppv',
  );

  await insertReservation(res, database);
  runApp(
    MaterialApp(
      home: Page_Controller(database),
    ),
  );
}
