/// ReservationProvider - Poskytovatel stavu a funkcnosti pre spravu rezervacii.
///
/// Autor: Marko Olešák xolesa00
/// 
/// Tato trieda spravuje zoznam rezervacii a interaguje s ReservationAPI
/// pre ziskavanie, vkladanie, aktualizaciu a mazanie rezervacii.
///
/// ## Funkcie
/// - Umoznuje ziskavat zoznam vsetkych rezervacii.
/// - Poskytuje metody pre vkladanie, aktualizaciu a mazanie rezervacii.
/// - Kontroluje platnost PIN kodu pre rezervacie.
/// - Spracovava pokutovanie neoverenych rezervacii po uplynuti 10 minut.
///
/// ## Pouzitie
/// Pouziva sa v spojeni s `Provider` balickom pre spristupnenie dat
/// o rezervaciach cez celej aplikacii.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vyperto/api/reservation_api.dart';
import 'package:vyperto/model/reservation.dart';

class ReservationProvider with ChangeNotifier {
  late ReservationAPI _reservationApi;
  List<Reservation> _reservations = [];

  ReservationProvider() {
    _reservationApi = ReservationAPI();
  }

  List<Reservation> get reservationsList => _reservations;

  Future<void> fetchReservations() async {
    final List<Reservation> fetchedReservations =
        await _reservationApi.fetchReservations();
    _reservations = fetchedReservations;

    // Pokutovane rezervacie, nie je overena a je po 10 minutach po zacati
    var expiredReservations = _reservations
        .where((reservation) =>
            reservation.isPinVerified == 0 &&
            DateTime.now()
                .isAfter(reservation.date.add(const Duration(minutes: 10))))
        .toList();

    for (Reservation reservation in expiredReservations) {
      reservation.isExpired = 1;
      _reservations.remove(reservation);
      await _reservationApi.updateReservation(reservation);
    }
    notifyListeners();
  }

  Future<void> providerInsertReservation(
    Reservation reservation,
  ) async {
    await _reservationApi.insertReservation(reservation);
    await fetchReservations();
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
    await _reservationApi.deleteReservation(reservation);
    await fetchReservations();
  }

  Future<bool> providerCheckPin(
    int pin,
    Reservation reservation,
  ) async {
    final bool isPinCorrect = await _reservationApi.checkPin(pin, reservation);
    return isPinCorrect;
  }
}
