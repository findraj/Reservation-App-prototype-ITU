import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vyperto/api/reservation_api.dart';
import 'package:vyperto/model/reservation.dart';
// import 'package:vyperto/view-model/profile_provider.dart';

class ReservationProvider with ChangeNotifier {
  late ReservationAPI _reservationApi;
  // late ProfileProvider _profileProvider; // TODO : cely profileprovider
  List<Reservation> _reservations = [];

  ReservationProvider() {
    _reservationApi = ReservationAPI();
  }

  List<Reservation> get reservationsList => _reservations;

  Future<void> fetchReservations() async {
    final List<Reservation> fetchedReservations = await _reservationApi.fetchReservations();
    _reservations = fetchedReservations;

    // Collect all expired reservations.
    var expiredReservations = _reservations.where((reservation) => reservation.isPinVerified == 0 && DateTime.now().isAfter(reservation.date.add(const Duration(minutes: 5)))).toList();

    // int reducedBalance = 0;
    for (Reservation reservation in expiredReservations) {
      reservation.isExpired = 1;
      // reducedBalance -= 10;
      _reservations.remove(reservation); // Remove the reservation from the list.
      await _reservationApi.updateReservation(reservation); // Update the reservation status in the database.
    }
    // if (reducedBalance != 0) _updateProfileBalance();
    notifyListeners(); // Notify listeners to rebuild UI if necessary.
  }

  Future<void> providerInsertReservation(
    Reservation reservation,
  ) async {
    await _reservationApi.insertReservation(reservation);
    await fetchReservations(); // Refresh the list of reservations
  }

  Future<void> providerUpdateReservation(
    Reservation reservation,
  ) async {
    await _reservationApi.updateReservation(reservation);
    await fetchReservations();
  }

  Future<void> providerDeleteReservation(
    Reservation reservation,
  ) async {
    await _reservationApi.deleteReservation(reservation); // Corrected to pass a Reservation object
    await fetchReservations();
  }

  Future<bool> providerCheckPin(
    int pin,
    Reservation reservation,
  ) async {
    final bool isPinCorrect = await _reservationApi.checkPin(pin, reservation);
    return isPinCorrect;
  }

  // void _updateProfileBalance() {
  //   // _profileProvider.updateProfileBalance( -10); // Call some method to update the profile balance
  // }
}
