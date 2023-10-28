import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vyperto/components/colors.dart';
import 'package:vyperto/components/fetch_reservations.dart';
import 'package:vyperto/components/reservation.dart';
import 'package:sqflite/sqflite.dart';

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
            child: FutureBuilder<List<Reservation>>(
              future: reservations(database),
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
                        elevation: 5, // Set the elevation
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Add rounded corners
                        ),
                        child: ListTile(
                          title: Text("Machine: ${reservation.machine}"),
                          subtitle: Text("Location: ${reservation.location}"),
                          // Add more information as needed
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
                  // Add your button click action here
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
