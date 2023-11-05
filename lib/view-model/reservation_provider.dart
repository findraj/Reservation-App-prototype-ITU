import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/api/database_api.dart';
import 'package:vyperto/model/reservation.dart';

class ReservationProvider with ChangeNotifier {
  final Database database;
  List<Reservation> _reservations = [];

  ReservationProvider(this.database);

  List<Reservation> get reservationsList => _reservations;

  Future<void> fetchReservations() async {
    final List<Reservation> reservationsList = await reservations(database);
    _reservations = reservationsList;
    notifyListeners();
  }

  Future<void> providerInsertReservation(Reservation reservation) async {
    await insertReservation(reservation, database);
    await fetchReservations(); // Refresh the list of reservations
  }

  Future<void> providerUpdateReservation(Reservation reservation) async {
    await updateReservation(reservation, database);
    await fetchReservations();
  }

  Future<void> providerDeleteReservation(int id) async {
    await deleteReservation(id, database);
    await fetchReservations();
  }
}
