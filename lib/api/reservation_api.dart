import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/model/reservation.dart';

class ReservationAPI {
  Future<Database> getReservationDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'reservation.db'),
      onCreate: (db, version) async {
        await db.execute(
          'DROP TABLE IF EXISTS reservations',
          //'CREATE TABLE reservations(id INTEGER PRIMARY KEY AUTOINCREMENT, machine TEXT, date INTEGER, location TEXT, isPinVerified BOOLEAN DEFAULT 0, isExpired BOOLEAN DEFAULT 0)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertReservation(Reservation reservation) async {
    Database db = await getReservationDB();
    await db.insert(
      'reservations',
      reservation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Reservation>> fetchReservations() async {
    Database db = await getReservationDB();
    final List<Map<String, dynamic>> maps = await db.query('reservations');

    return List.generate(maps.length, (i) {
      return Reservation(
        id: maps[i]['id'] as int,
        machine: maps[i]['machine'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(maps[i]['date'] as int),
        location: maps[i]['location'] as String,
        isPinVerified: maps[i]['isPinVerified'] as int,
        isExpired: maps[i]['isExpired'] as int,
      );
    });
  }

  Future<void> updateReservation(Reservation reservation) async {
    Database db = await getReservationDB();
    await db.update(
      'reservations',
      reservation.toMap(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<void> deleteReservation(Reservation reservation) async {
    Database db = await getReservationDB();
    await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<bool> checkPin(int pin, Reservation reservation) async {
    print(reservation.toString());
    DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0'); // DD
    String month = now.month.toString().padLeft(2, '0'); // MM
    int todaysPin = int.parse(day + month); // DDMM pin pre dnesny den

    if (todaysPin == pin) {
      reservation.isPinVerified = 1;
      await updateReservation(reservation);
    }
    // Skontroluj ci sa pin rovna datumu
    return reservation.isPinVerified == 1 ? true : false;
  }
}
