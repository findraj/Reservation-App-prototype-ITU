import 'package:flutter/material.dart';
import 'package:vyperto/assets/colors.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/model/reservation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  final Database database;
  HomeScreen(this.database);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ahoj, Marko!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Zostatok : XXXX",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Čas vyprať ?",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 2,
            thickness: 1,
            color: Colors.black,
          ),
          Expanded(
            child: Consumer<ReservationProvider>(
              builder: (context, reservationProvider, child) {
                final reservationsList = reservationProvider.reservationsList;

                if (reservationsList.isEmpty) {
                  return const Center(child: Text("No reservations found."));
                } else {
                  return ListView.builder(
                    itemCount: reservationsList.length,
                    itemBuilder: (context, index) {
                      Reservation reservation = reservationsList[index];
                      String formattedDate = DateFormat('yyyy-MM-dd').format(reservation.date); // Date formatting
                      String formattedTime = DateFormat('HH:mm').format(reservation.date); // Time formatting

                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text("Machine: ${reservation.machine}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height:5),
                              Text("Location: ${reservation.location}"),
                              const SizedBox(height:5),
                              Text("Date: $formattedDate"), 
                              const SizedBox(height:5),
                              Text("Time: $formattedTime"), 
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              reservationProvider.providerDeleteReservation(reservation.id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  var newReserv = Reservation(
                      id: DateTime.now().millisecondsSinceEpoch,
                      machine: 'susicka',
                      date: DateTime.now(),
                      location: 'PPV');
                  Provider.of<ReservationProvider>(context, listen: false).providerInsertReservation(newReserv);
                },
                child: const Text('Nová rezervácia'),
              ),
            ],
          )
        ],
      ),
      backgroundColor: primaryColor,
    );
  }
}
