import 'package:flutter/material.dart';
import 'package:vyperto/assets/colors.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/model/profile.dart';
import 'package:provider/provider.dart';
import 'package:vyperto/assets/profile_info.dart';

class OdmenyScreen extends StatefulWidget {
  const OdmenyScreen({super.key});

  @override
  _OdmenyScreenState createState() => _OdmenyScreenState();
}

class _OdmenyScreenState extends State<OdmenyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          primaryColor, // Assuming you have defined primaryColor in 'colors.dart'
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              Profile fetchedProfile = profileProvider.profile;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 0),
                    child: ProfileHeader(
                        profile:
                            fetchedProfile), // Now only ProfileHeader has padding
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        top: 0,
                        left: 10,
                        right: 10,
                        bottom: 0), // Added padding for alignment

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 16.0), // Added padding for alignment
                          child: Text(
                            'Kupóny',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: fetchedProfile.body >= 10 ? 8 : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: const Text("Pranie zadarmo!"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                fetchedProfile.body < 10
                                    ? Text(
                                        "Dostupné od 10 bodov, máš: ${fetchedProfile.body}")
                                    : const Text("Hurá!"),
                                const SizedBox(height: 5),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Ensures the row only takes up needed space
                              children: [
                                if (fetchedProfile.body >= 10)
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<
                                              Color>(
                                          selectedItemColor), // Use an appropriate Color object here
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Použiť',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                    onPressed: () {
                                      widget.onNavigateToRezervacia();
                                    },
                                  ),
                                if (fetchedProfile.body < 10)
                                  const Icon(
                                    size: 32,
                                    Icons.lock,
                                    color: Colors.grey,
                                  )
                              ],
                            ),
                          ),
                        ),
                        Card(
                          elevation: fetchedProfile.body >= 7 ? 8 : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: const Text("Sušenie zadarmo!"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                fetchedProfile.body < 7
                                    ? Text(
                                        "Dostupné od 7 bodov, máš: ${fetchedProfile.body}")
                                    : const Text("Hurá!"),
                                const SizedBox(height: 5),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Ensures the row only takes up needed space
                              children: [
                                if (fetchedProfile.body >= 7)
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<
                                              Color>(
                                          selectedItemColor), // Use an appropriate Color object here
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Použiť',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                    onPressed: () {
                                      widget.onNavigateToRezervacia();
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
