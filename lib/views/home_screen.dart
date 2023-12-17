import 'package:flutter/material.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/view-model/account_provider.dart';
import 'package:vyperto/model/reservation.dart';
import 'package:vyperto/model/profile.dart';
import 'package:vyperto/model/account.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vyperto/assets/profile_info.dart';
import 'dart:async';

import 'package:vyperto/views/odmeny_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToRezervacia;

  const HomeScreen({Key? key, required this.onNavigateToRezervacia}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nearestpinController = TextEditingController();
  final TextEditingController _secondpinController = TextEditingController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    const Duration refreshRate = Duration(minutes: 1);

    _timer = Timer.periodic(refreshRate, (timer) {
      if (mounted) {
        final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
        reservationProvider.fetchReservations();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Text(
              'Aktuálne rezervácie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<ReservationProvider>(
              builder: (context, reservationProvider, child) {
                final reservationsList = reservationProvider.reservationsList;
                reservationsList.sort((a, b) => a.date.compareTo(b.date));

                if (reservationsList.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Aktuálne nemáš žiadne rezervácie.."),
                          const SizedBox(height: 10),
                          const Text("😢", style: TextStyle(fontSize: 24)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  widget.onNavigateToRezervacia();
                                },
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(6.0),
                                ),
                                child: const Text('Vytvor si novú rezerváciu!'),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
                      reservationProvider.fetchReservations();
                    },
                    child: ListView.builder(
                      itemCount: reservationsList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Reservation reservation = reservationsList[index];

                        // Kontrola ci je rezervacia expirovana
                        bool isExpired = false;
                        if (reservation.machine == "Pranie a sušenie" && reservation.date.isBefore(DateTime.now().subtract(const Duration(hours: 2, minutes: 30)))) {
                          isExpired = true;
                        } else if (reservation.machine != "Pranie a sušenie" && reservation.date.isBefore(DateTime.now().subtract(const Duration(hours: 1, minutes: 30)))) {
                          isExpired = true;
                        }

                        // Nastav atribut isExpired v databaze na 1 ak je rezervacia expirovana
                        if (isExpired && reservation.isExpired != 1) {
                          reservation.isExpired = 1;
                          reservationProvider.providerUpdateReservation(reservation);
                        }

                        // Nevypis rezervaciu ak je expirovana
                        if (isExpired) {
                          return const SizedBox.shrink();
                        }

                        String formattedDate = DateFormat('yyyy-MM-dd').format(reservation.date);
                        String formattedTime = (reservation.machine == "Pranie a sušenie")
                            ? DateFormat('HH:mm').format(reservation.date) + " - " + DateFormat('HH:mm').format(reservation.date.add(const Duration(hours: 2)))
                            : DateFormat('HH:mm').format(reservation.date) + " - " + DateFormat('HH:mm').format(reservation.date.add(const Duration(hours: 1)));

                        bool isNearest = index == 0; // Najblizsia rezervacia ma index 0 po sorte
                        bool isSecondNearest = index == 1; // Druha najblizsia rezervacia ma index 1 po sorte

                        return Card(
                          elevation: !(reservation.isPinVerified == 1) ? 5 : 3,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text("${reservation.machine}", style: (reservation.isPinVerified == 1) ? const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 51, 213, 135)) : null),
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
                                if ((isNearest || isSecondNearest) && reservation.isPinVerified != 1 && (DateTime.now().isAfter(reservation.date.subtract(const Duration(minutes: 10))) && DateTime.now().isBefore(reservation.date.add(const Duration(minutes: 20)))))
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
                                if (DateTime.now().isBefore(reservation.date.subtract(const Duration(hours: 2))))
                                  IconButton(
                                      iconSize: 24,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.edit_calendar, color: Colors.blue), // You can replace Icons.edit with the desired edit icon
                                      onPressed: () {
                                        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                                        profileProvider.setEditingReservation(true);
                                        profileProvider.setCurrentReservation(reservation);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Vyberte nový čas rezervácie!'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        widget.onNavigateToRezervacia();
                                      }),
                                const SizedBox(width: 10),
                                if (DateTime.now().isBefore(reservation.date.subtract(const Duration(minutes: 10))))
                                  IconButton(
                                    iconSize: 24,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      bool? confirmDelete = await showDialog<bool>(
                                        barrierDismissible: true, // Uzivatel moze kliknut mimo dialog a zrusit ho
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Potvrďte zmazanie rezervácie"),
                                            content: const Text("Ste si istý, že chcete zmazať rezerváciu?"),
                                            actions: [
                                              ButtonBar(
                                                alignment: MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    child: TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.redAccent,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop(true);
                                                      },
                                                      child: const Text(
                                                        "Áno",
                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    child: TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.greenAccent,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop(false);
                                                      },
                                                      child: const Text(
                                                        "Nie",
                                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmDelete == true) {
                                        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                                        final int refundAmount = reservation.machine.contains("sušenie") ? COST_WASHING_DRYING : COST_WASHING;
                                        Account account = Account(
                                            balance: Provider.of<ProfileProvider>(context, listen: false).profile.zostatok,
                                            price: refundAmount,
                                        );
                                        Provider.of<AccountProvider>(context, listen: false).providerInsertAccount(account);
                                        final int body = reservation.machine.contains("sušenie") ? COST_WASHING_DRYING : COST_WASHING;

                                        if (reservation.wasFree == 1) {
                                          // -1 lebo bol bod pridany pri vytvoreni rezervacie
                                          profileProvider.updateProfilePoints(profileProvider.profile, body);
                                        } else {
                                          profileProvider.updateProfileBalance(profileProvider.profile, refundAmount);
                                        }
                                        reservationProvider.providerDeleteReservation(reservation);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Rezervácia bola úspešne zrušená, peniaze/body vám boli vrátené na konto')),
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      }, // else
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    ));
  }
}
