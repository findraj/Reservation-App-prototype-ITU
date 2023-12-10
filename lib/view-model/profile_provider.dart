import 'package:flutter/foundation.dart';
import 'package:vyperto/api/profile_api.dart';
import 'package:vyperto/model/profile.dart';

class ProfileProvider extends ChangeNotifier {
  late ProfileAPI _profileApi;

  late Profile _profile;

  ProfileProvider() {
    _profileApi = ProfileAPI();
    _profile = Profile(meno: "", priezvisko: "", email: "", zostatok: 0, body: 0, miesto: "", darkMode: 0);
    fetchProfile(_profile);
  }

  Profile get profile => _profile;

  Future<void> providerInsertProfile(Profile profile) async {
    try {
      await _profileApi.insertProfile(profile);
      await fetchProfile(profile);
    } catch (e) {
      print('Error inserting profile: $e');
      rethrow;
    }
  }

  Future<void> fetchProfile(Profile profile) async {
    try {
      _profile = await _profileApi.getProfile(_profile);
      notifyListeners();
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> updateProfileBalance(Profile profile, int amount) async {
    try {
      _profile.zostatok += amount;
      await _profileApi.manipulateBalance(profile, amount);
      notifyListeners();
    } catch (e) {
      print('Error updating balance: $e');
      rethrow;
    }
  }
}