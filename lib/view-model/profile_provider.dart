import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/api/profile_api.dart';
import 'package:vyperto/model/profile.dart';

class ProfileProvider with ChangeNotifier {
  final Database database;
  Profile _profile = Profile();

  ProfileProvider(this.database);

  Profile get profile => _profile;

Future<void> providerInsertProfile(Profile profile) async {
    try {
      await insertProfile(profile, database);
      await fetchProfile(profile.id);
    } catch (e) {
      print('Error inserting profile: $e');
      rethrow;
    }
  }

  Future<void> fetchProfile(int id) async {
    final Profile profile = await getProfile(database, id);
    _profile = profile;
    notifyListeners();
  }

  Future<void> updateProfileBalance(int id, int amount) async {
    try {
      _profile.zostatok += amount;
      await manipulateBalance(database, id, amount);
      notifyListeners();
    } catch (e) {
      print('Error updating balance: $e');
      rethrow;
    }
  }
}
