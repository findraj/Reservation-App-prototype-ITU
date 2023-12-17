/// `OdmenyScreen` obrazovka s odmenami pre uzivatela.
///
///  Autor: Marko Olešák xolesa00
///
/// Obrazovka zobrazuje odmeny, ktore si uzivatel moze ziskat za body.
/// Zobrazenie je v podobe zoznamu, ktory obsahuje karticky s odmenami.
/// Kazda odmena ma svoju cenu v bodoch, ktora je zobrazena v karticke.
///
/// ## Funkcionalita
/// - Zobrazenie odmien, ci uz dostupnych alebo nedostupnych.
/// - Umoznuje pouzit odmenu, ak ma uzivatel dostatok bodov.
///

import 'package:flutter/material.dart';
import 'package:vyperto/assets/colors.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/model/profile.dart';
import 'package:provider/provider.dart';
import 'package:vyperto/assets/profile_info.dart';

class OdmenyScreen extends StatefulWidget {
  final VoidCallback onNavigateToRezervacia;

  const OdmenyScreen({Key? key, required this.onNavigateToRezervacia}) : super(key: key);

  @override
  _OdmenyScreenState createState() => _OdmenyScreenState();
}

const int COST_WASHING = 10;
const int COST_WASHING_DRYING = 17;

class _OdmenyScreenState extends State<OdmenyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                    child: ProfileHeader(profile: fetchedProfile),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
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
                          elevation: fetchedProfile.body >= COST_WASHING ? 8 : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: const Text("Pranie zadarmo!"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                fetchedProfile.body < COST_WASHING ? Text("Dostupné od ${COST_WASHING} bodov, máš: ${fetchedProfile.body}") : const Text("Hurá! Cena: ${COST_WASHING} bodov"),
                                const SizedBox(height: 5),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (fetchedProfile.body >= COST_WASHING)
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(selectedItemColor),
                                      padding: MaterialStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Použiť',
                                      style: TextStyle(fontSize: 12, color: Colors.white),
                                    ),
                                    onPressed: () {
                                      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                                      profileProvider.setUsingReward(true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Rezervácia bude zaplatená z vernostných bodov!'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      widget.onNavigateToRezervacia();
                                    },
                                  ),
                                if (fetchedProfile.body < COST_WASHING)
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
                          elevation: fetchedProfile.body >= COST_WASHING_DRYING ? 8 : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: const Text("Pranie a sušenie zadarmo!"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                fetchedProfile.body < COST_WASHING_DRYING ? Text("Dostupné od ${COST_WASHING_DRYING} bodov, máš: ${fetchedProfile.body}") : const Text("Hurá! Cena: ${COST_WASHING_DRYING} bodov"),
                                const SizedBox(height: 5),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (fetchedProfile.body >= COST_WASHING_DRYING)
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(selectedItemColor),
                                      padding: MaterialStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Použiť',
                                      style: TextStyle(fontSize: 12, color: Colors.white),
                                    ),
                                    onPressed: () {
                                      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                                      profileProvider.setUsingReward(true);
                                      widget.onNavigateToRezervacia();
                                    },
                                  ),
                                if (fetchedProfile.body < COST_WASHING_DRYING)
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
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const ListTile(
                            title: Text("Ďalšie odmeny už čoskoro!"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Text("Ale to je zatial tajné..."),
                                SizedBox(height: 5),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  size: 32,
                                  Icons.lock,
                                  color: Colors.grey,
                                )
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
