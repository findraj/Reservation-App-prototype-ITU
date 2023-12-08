import 'package:flutter/material.dart';
import 'package:vyperto/assets/colors.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/model/reservation.dart';
import 'package:vyperto/model/profile.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vyperto/assets/profile_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _washpinController = TextEditingController();

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
        backgroundColor: primaryColor,
        body: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ProfileProvider>(builder: (context, profileProvider, child) {
                Profile fetchedProfile = profileProvider.profile;
                return Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                  child: ProfileHeader(profile: fetchedProfile), // Now only ProfileHeader has padding
                );
              }),
              const SizedBox(height: 8),
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
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Reservation reservation = reservationsList[index];
                          String formattedDate = DateFormat('yyyy-MM-dd').format(reservation.date); // Date formatting
                          String formattedTime = DateFormat('HH:mm').format(reservation.date); // Time formatting

                          bool isNearest = index == 0; // Najblizsia rezervacia ma index 0 po sorte
                          return Card(
                            elevation: isNearest ? 5 : 3,
                            margin: const EdgeInsets.only(bottom: 10),
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
                                  Text(
                                    "Date: $formattedDate",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isNearest && DateTime.now().isAfter(reservation.date) ? Colors.red : null, // If nearest reservation and time is past, then red
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Time: $formattedTime",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isNearest && DateTime.now().isAfter(reservation.date) ? Colors.red : null,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Pole na zadanie pinu sa objavi 5 minut pred rezervaciou a zmizne, ak je rezervacia viac ako 15 minut po
                                  if (isNearest && (DateTime.now().isAfter(reservation.date.subtract(const Duration(minutes: 5))) && DateTime.now().isBefore(reservation.date.add(const Duration(minutes: 20)))))
                                    SizedBox(
                                      width: 75,
                                      child: TextField(
                                          controller: _washpinController,
                                          keyboardType: TextInputType.number,
                                          maxLength: 4,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            hintText: 'Zadaj PIN',
                                          ),
                                          onChanged: (String value) async {
                                            if (value.length == 4) {
                                              bool pinOk = await reservationProvider.providerCheckPin(int.parse(value));
                                              if (pinOk) {
                                                // pin v poriadku
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Zadanie pinu úspešné!'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              } else {
                                                // Ak je pin nespravny, tak sa zobrazi snackbar s chybovou hlaskou
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Nesprávny PIN!'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                              _washpinController.clear();
                                              // Overenie pinu
                                              print("PIN: $value");
                                            }
                                          }),
                                    ),
                                  const SizedBox(width: 15),
                                  IconButton(
                                    iconSize: 24,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
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
        ));
  }
}
