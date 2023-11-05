import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/model/reservation.dart';

Future<Database> initializeDB() async {
  try {
    final String path = join(await getDatabasesPath(), 'reservation.db');
    print('Database path: $path');
    Database db = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE reservations(id INTEGER PRIMARY KEY AUTOINCREMENT, machine TEXT, date INTEGER, location TEXT)',
        );
      },
      version: 1,
    );
    print('Database initialized successfully');
    return db;
  } catch (e) {
    print('Error initializing the database: $e');
    rethrow; // Rethrow the exception so that it can be handled elsewhere if needed.
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
