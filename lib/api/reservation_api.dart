import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/model/reservation.dart';

Future<Database> initializeReservationDB() async {
  try {
    final String path = join(await getDatabasesPath(), 'reservation.db');
    print('Database path: $path');
    Database db = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          // 'DROP TABLE IF EXISTS reservations',
          'CREATE TABLE reservations(id INTEGER PRIMARY KEY AUTOINCREMENT, machine TEXT, date INTEGER, location TEXT, isPinVerified INTEGER)',
        );
      },
      version: 1,
    );
    print('Database initialized successfully');
    return db;
  } catch (e) {
    print('Error initializing the database: $e');
    rethrow;
  }
}

Future<void> insertReservation(Reservation reservation, Database db) async {
  await db.insert(
    'reservations',
    reservation.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Reservation>> reservations(Database db) async {
  final List<Map<String, dynamic>> maps = await db.query('reservations');

  return List.generate(maps.length, (i) {
    return Reservation(
      id: maps[i]['id'] as int,
      machine: maps[i]['machine'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(maps[i]['date'] as int),
      location: maps[i]['location'] as String,
      isPinVerified: maps[i]['isPinVerified'] as int,
    );
  });
}

Future<void> updateReservation(Reservation reservation, Database db) async {
  await db.update(
    'reservations',
    reservation.toMap(),
    where: 'id = ?',
    whereArgs: [reservation.id],
  );
}

Future<void> deleteReservation(int id, Database db) async {
  await db.delete(
    'reservations',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<bool> checkPin(int pin, Reservation reservation, Database db) async {
  DateTime now = DateTime.now();
  String day = now.day.toString().padLeft(2, '0'); // DD
  String month = now.month.toString().padLeft(2, '0'); // MM
  int todaysPin = int.parse(day + month); // DDMM pin pre dnesny den 

  if (todaysPin == pin) {
    reservation.isPinVerified = 1;
    await updateReservation(reservation, db);
  }
  // Skontroluj ci sa pin rovna datumu
  return reservation.isPinVerified == 1 ? true : false;
}
