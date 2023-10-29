import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vyperto/components/colors.dart';
import 'package:vyperto/components/fetch_reservations.dart';
import 'package:vyperto/components/reservation.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  final Database database;

  HomeScreen(this.database);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Reservation>>? _reservations;

  @override
  void initState() {
    super.initState();
    _refreshReservations();
  }

  _refreshReservations() {
    setState(() {
      _reservations = reservations(widget.database);
    });
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
            child: FutureBuilder<List<Reservation>>(
              future: _reservations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.data?.isEmpty ?? true) {
                  return Center(child: Text("No reservations found."));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      Reservation reservation = snapshot.data?[index] ??
                          Reservation(
                            id: 0,
                            machine: 'No machine',
                            date: DateTime.now(),
                            location: 'No location',
                          );
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text("Machine: ${reservation.machine}"),
                          subtitle: Text("Location: ${reservation.location}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await deleteReservation(
                                  reservation.id, widget.database);
                              _refreshReservations();
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
                  insertReservation(newReserv, widget.database);
                  _refreshReservations();
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
