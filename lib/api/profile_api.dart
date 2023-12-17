/// `profile_api` API profilu
///
///  Autor: Marko Olešák xolesa00
/// 
/// API profilu, ktore obsahuje vsetky potrebne metody na pracu s databazou.
/// Obsahuje metody na vytvorenie, ziskanie, aktualizaciu a vymazanie profilu.
///
/// ## Funkcionalita
/// - Vytvorenie databazy.
/// - Vlozenie profilu do databazy.
/// - Ziskanie profilu z databazy.
/// - Aktualizacia profilu v databaze.
/// - Manipulacia s zostatkom.
/// - Manipulacia s bodmi.
/// - a pod.
///
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/model/profile.dart';

class ProfileAPI {
  Future<Database> getProfileDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'profile.db'),
      onCreate: (db, version) async {
        await db.execute(
          // 'DROP TABLE IF EXISTS profiles',
          'CREATE TABLE profiles(id INTEGER PRIMARY KEY, meno TEXT, priezvisko TEXT, email TEXT, zostatok INTEGER, body INTEGER, miesto TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> updateBalance(Profile profile) async {
    Database db = await getProfileDB();
    await db.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<Profile> getProfile(Profile profile) async {

    Database db = await getProfileDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [profile.id],
    );

    if (maps.isNotEmpty) {
      // Use the existing Profile instance's id
      return Profile(
        meno: maps[0]['meno'] as String,
        priezvisko: maps[0]['priezvisko'] as String,
        email: maps[0]['email'] as String,
        zostatok: maps[0]['zostatok'] as int,
        body: maps[0]['body'] as int,
        miesto: maps[0]['miesto'] as String,
      );
    } else {
      throw Exception('Profile with id ${profile.id} not found');
    }
  }

  Future<void> insertProfile(Profile profile) async {
    Database db = await getProfileDB();
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

  Future<void> manipulateBalance(Profile profile, int amount) async {
    try {
      Profile fetchedProfile = await getProfile(profile);
      fetchedProfile.zostatok += amount;
      await updateBalance(profile);
      print('Balance manipulated successfully');
    } catch (e) {
      print('Error manipulating balance: $e');
    }
  }
}
