import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/page_controller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/api/database_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Database database = await initializeDB();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ReservationProvider(database),
      child: MaterialApp(
        home: Page_Controller(database),
      ),
    ),
  );
}
