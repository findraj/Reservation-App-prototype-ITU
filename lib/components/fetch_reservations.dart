import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'reservation.dart';

  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'reservation.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE reservations(id INTEGER PRIMARY KEY, machine TEXT, date INTEGER, location INTEGER)',
      );
    },
    version: 1,
  );

  Future<void> insertReservation(Reservation reservation) async {
    final db = await database;

    await db.insert(
      'reservation',
      reservation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Reservation>> reservations() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('dogs');

    return List.generate(maps.length, (i) {
      return Reservation(
        id: maps[i]['id'] as int,
        machine: maps[i]['machine'] as String,
        date: maps[i]['date'] as DateTime,
        location: maps[i]['location'] as String
      );
    });
  }

  Future<void> updateReservation(Reservation reservation) async {
    final db = await database;

    await db.update(
      'reservations',
      reservation.toMap(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<void> deleteReservation(int id) async {
    final db = await database;

    await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }