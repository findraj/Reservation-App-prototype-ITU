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
  final VoidCallback onNavigateToRezervacia;

  const HomeScreen({Key? key, required this.onNavigateToRezervacia})
      : super(key: key);

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
            Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
              profileProvider.fetchProfile(profileProvider.profile);
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
                    return const Center(
                      child: Text("Neboli nájdené žiadne rezervácie.."),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: reservationsList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // ... existing ListView.builder code ...
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
                        machine: 'Pranie',
                        date: DateTime.now(),
                        location: 'PPV',
                        isPinVerified: 0,
                        isExpired: 0);
                    Provider.of<ReservationProvider>(context, listen: false)
                        .providerInsertReservation(newReserv);
                    widget.onNavigateToRezervacia();
                  },
                  child: const Text('Nová rezervácia'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
