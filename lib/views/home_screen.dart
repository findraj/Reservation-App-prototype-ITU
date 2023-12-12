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
  final TextEditingController _nearestpinController = TextEditingController();
  final TextEditingController _secondpinController = TextEditingController();

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
                profileProvider.fetchProfile(profileProvider.profile); // Nacitanie profilu z databazy
                Profile fetchedProfile = profileProvider.profile;
                return ProfileHeader(profile: fetchedProfile);
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
                          bool isSecondNearest = index == 1; // Druha najblizsia rezervacia ma index 1 po sorte
                          return Card(
                            elevation: !(reservation.isPinVerified == 1) ? 5 : 3,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text("${reservation.machine}", style: (reservation.isPinVerified == 1) ? TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 51, 213, 135)) : null),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text("Miesto: ${reservation.location}"),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Dátum: $formattedDate",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (isNearest || isSecondNearest) && !(reservation.isPinVerified == 1) && DateTime.now().isAfter(reservation.date) ? Colors.red : null, // If nearest reservation and time is past, then red
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Čas: $formattedTime",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (isNearest || isSecondNearest) && !(reservation.isPinVerified == 1) && DateTime.now().isAfter(reservation.date) ? Colors.red : null,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Pole na zadanie pinu sa objavi 5 minut pred rezervaciou a zmizne, ak je rezervacia viac ako 15 minut po
                                  if ((isNearest || isSecondNearest) && reservation.isPinVerified != 1 && (DateTime.now().isAfter(reservation.date.subtract(const Duration(minutes: 5))) && DateTime.now().isBefore(reservation.date.add(const Duration(minutes: 20)))))
                                    SizedBox(
                                      width: 75,
                                      child: TextField(
                                          controller: isNearest ? _nearestpinController : _secondpinController,
                                          keyboardType: TextInputType.number,
                                          maxLength: 4,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            hintText: 'Zadaj PIN',
                                          ),
                                          onChanged: (String value) async {
                                            if (value.length == 4) {
                                              bool pinOk = await reservationProvider.providerCheckPin(int.parse(value), reservation);
                                              if (pinOk) {
                                                setState(() {});
                                                // pin v poriadku
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    backgroundColor: Colors.greenAccent,
                                                    content: Text('Zadanie pinu úspešné!'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                                isNearest ? _nearestpinController.clear() : _secondpinController.clear();
                                              } else {
                                                // Ak je pin nespravny, tak sa zobrazi snackbar s chybovou hlaskou
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    backgroundColor: Color.fromARGB(255, 255, 103, 103),
                                                    content: Text('Nesprávny PIN!'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                                isNearest ? _nearestpinController.clear() : _secondpinController.clear();
                                              }
                                              // Overenie pinu
                                              print("User input : PIN: $value");
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
                                      reservationProvider.providerDeleteReservation(reservation);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }, // else
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
                      var newReserv = Reservation(id: DateTime.now().millisecondsSinceEpoch, machine: 'Pranie', date: DateTime.now(), location: Provider.of<ProfileProvider>(context, listen: false).profile.miesto, isPinVerified: 0, isExpired: 0);
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
