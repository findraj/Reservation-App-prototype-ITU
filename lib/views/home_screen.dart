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

  void _showPinDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController pinController = TextEditingController();
        return AlertDialog(
          title: const Text('Zadajte PIN z obrazovky'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(hintText: 'Zadajte 4-miestny PIN'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Overiť'),
              onPressed: () {
                //# Overenie pinu
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
                reservationsList.sort((a, b) => a.date.compareTo(b.date));

                if (reservationsList.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Neboli nájdené žiadne rezervácie.."),
                          SizedBox(height: 10),
                          Text("😢", style: TextStyle(fontSize: 24)),
                        ],
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: reservationsList.length,
                    itemBuilder: (context, index) {
                      Reservation reservation = reservationsList[index];
                      String formattedDate = DateFormat('yyyy-MM-dd').format(reservation.date); // Date formatting
                      String formattedTime = DateFormat('HH:mm').format(reservation.date); // Time formatting

                      bool isNearest = index == 0; // Najblizsia rezervacia ma index 0 po sorte

                      return Card(
                        color: DateTime.now().isAfter(reservation.date) ? const Color.fromARGB(255, 220, 169, 160) : null, // Nastav farbu karty podla casu
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text("Machine: ${reservation.machine}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text("Location: ${reservation.location}"),
                              const SizedBox(height: 5),
                              Text("Date: $formattedDate"),
                              const SizedBox(height: 5),
                              Text("Time: $formattedTime"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min, // Ensures the column only takes up needed space
                            children: [
                              if (isNearest)
                                TextButton(
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all<double>(5),
                                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 75, 204, 141)),
                                    padding: MaterialStateProperty.all<EdgeInsets>(
                                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                  child: const Text(
                                    'START',
                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                  onPressed: () {
                                    _showPinDialog(context);
                                  },
                                ),
                              const SizedBox(width: 15),
                              IconButton(
                                iconSize: 24, // Adjust icon size if necessary
                                padding: EdgeInsets.zero, // Remove any padding around the icon button
                                constraints: const BoxConstraints(), // Reset constraints to allow for smaller size
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  reservationProvider.providerDeleteReservation(reservation.id);
                                },
                              ),
                            ],
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
                  var newReserv = Reservation(id: DateTime.now().millisecondsSinceEpoch, machine: 'susicka', date: DateTime.now(), location: 'PPV');
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
