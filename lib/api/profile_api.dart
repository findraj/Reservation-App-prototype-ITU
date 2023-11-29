import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/model/profile.dart';

Future<Database> initializeProfileDB() async {
  try {
    final String path = join(await getDatabasesPath(), 'profile.db');
    print('Database path: $path');
    Database db = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE profiles(id INTEGER PRIMARY KEY, meno TEXT, email TEXT, zostatok INTEGER, body INTEGER)',
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

Future<void> updateBalance(Profile profile, Database db) async {
  await db.update(
    'profiles',
    profile.toMap(),
    where: 'id = ?',
    whereArgs: [profile.id],
  );
}

Future<Profile> getProfile(Database db, int id) async {
  final List<Map<String, dynamic>> maps = await db.query(
    'profiles',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    // Create a Profile from the first map since we expect only one profile with this ID
    return Profile()
      ..meno = maps[0]['meno'] as String
      ..email = maps[0]['email'] as String
      ..zostatok = maps[0]['zostatok'] as int
      ..body = maps[0]['body'] as int;
  } else {
    throw Exception('Profile with id $id not found');
  }
}

Future<void> insertProfile(Profile profile, Database db) async {
  try {
    await db.insert(
      'profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Profile inserted successfully');
  } catch (e) {
    print('Error inserting profile: $e');
    rethrow;
  }
}

Future<void> manipulateBalance(Database db, int id, int amount) async {
  try {
    Profile profile = await getProfile(db, id);
    profile.zostatok += amount;
    await updateBalance(profile, db);
    print('Balance manipulated successfully');
  } catch (e) {
    print('Error manipulating balance: $e');
  }
}


