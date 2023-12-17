/// profile_route.dart
/// obrazovka profilu
///
/// Autor: Jan Findra (xfindr01)
///
/// Sprava profilu, financii, dobyjanie penazi, historia rezervacii a transakcii
///
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyperto/assets/colors.dart';
import 'package:vyperto/model/account.dart';
import 'package:vyperto/model/reservation.dart';
import 'package:vyperto/model/profile.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/view-model/account_provider.dart';

class ProfileRoute extends StatefulWidget {
  const ProfileRoute({super.key});

  @override
  _ProfileRouteState createState() => _ProfileRouteState();
}

class _ProfileRouteState extends State<ProfileRoute> {
  List<String> locations = ['Koleje pod Palackého vrchem', 'Purkyňove koleje']; // Available locations
  TextEditingController _codeController = TextEditingController(); // Controller for code input

  // State variables for user information
  String userName = 'example';
  String userSurname = 'example';
  String userNameFull = 'example';
  String userEmail = 'example@example.com';
  int chargedMoney = 0;

  // Function to change balance
  Future<void> _changeBalance() async {
    TextEditingController _balanceController = TextEditingController();

    showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Dobyť peniaze'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Suma'),
              ),
            ]
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Zrušiť'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  chargedMoney = int.parse(_balanceController.text);
                });
                if (chargedMoney > 0){
                  Provider.of<ProfileProvider>(context, listen: false).updateProfileBalance(Provider.of<ProfileProvider>(context, listen: false).profile, chargedMoney);
                  Account account = Account(
                    balance: Provider.of<ProfileProvider>(context, listen: false).profile.zostatok,
                    price: chargedMoney,
                    );
                  Provider.of<AccountProvider>(context, listen: false).providerInsertAccount(account);
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color.fromARGB(255, 255, 103, 103),
                      content: Text('Suma musí byť väčšia ako 0'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: Text('Uložiť'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAccountHistory() async {
    // Fetch accounts once using Provider outside the Consumer
    Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
  
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<AccountProvider>(
          builder: (context, accountProvider, child) {
            List<Account> historyAccounts = accountProvider.accountsList;
  
            return AlertDialog(
              title: Text('História financií'),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: historyAccounts.length,
                  itemBuilder: (context, index) {
                    Account account = historyAccounts[historyAccounts.length - 1 - index];
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${account.price! > 0 ? '+' : ''}${account.price} CZK',
                            style: TextStyle(
                              color: (account.price! > 0) ? Colors.green : Colors.red,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${account.balance} CZK\n${account.balance! - account.price!} CZK',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Delete all accounts in historyAccounts
                    for (Account account in List.from(historyAccounts)) {
                      Provider.of<AccountProvider>(context, listen: false).providerDeleteAccount(account);
                    }
                    // Update the UI by fetching accounts again
                    accountProvider.fetchAccounts();
                    Navigator.pop(context);
                  },
                  child: Text('Vymazať históriu'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Zrušiť'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  // Function to edit user profile
  Future<void> _editProfile() async {
    TextEditingController _nameController = TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).profile.meno);
    TextEditingController _surnameController = TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).profile.priezvisko);
    TextEditingController _emailController = TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).profile.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upraviť profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Surname'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'e-mail'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Zrušiť'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  userName = _nameController.text;
                  userSurname = _surnameController.text;
                  userEmail = _emailController.text;
                });
                Profile previousProfile = Provider.of<ProfileProvider>(context, listen: false).profile;
                Profile newProfile = Profile(
                  meno: userName,
                  priezvisko: userSurname,
                  email: userEmail,
                  zostatok: previousProfile.zostatok,
                  body: previousProfile.body,
                  miesto: previousProfile.miesto,
                  darkMode: previousProfile.darkMode,
                );
                Provider.of<ProfileProvider>(context, listen: false).providerInsertProfile(newProfile);

                Navigator.pop(context);
              },
              child: Text('Uložiť'),
            ),
          ],
        );
      },
    );
  }

  List<Reservation> _generateMockReservations() {
    Random random = Random();
    List<Reservation> mockReservations = [];
    for (int i = 0; i < 5; i++) {
      mockReservations.add(
        Reservation(
          id: i,
          date: DateTime.now().subtract(Duration(days: random.nextInt(30))),
          location: locations[random.nextInt(locations.length)],
          machine: 'Machine ${random.nextInt(10) + 1}',
          isPinVerified: random.nextInt(2),
          isExpired: random.nextInt(2),
          wasFree: random.nextInt(2),
        ),
      );
    }
    return mockReservations;
  }

  @override
  Widget build(BuildContext context) {
    List<Reservation> historyReservations = Provider.of<ReservationProvider>(context, listen: true).reservationsList;
    List<Reservation> filteredReservations = historyReservations
      .where((reservation) =>
          reservation.isPinVerified == 1 || reservation.isExpired == 1)
      .toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: appBarBackgroundColor,
        title: const Text(
          "Profil",
          style: TextStyle(
            color: appBarIconColor,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User information with profile picture and edit option
          Row(
            children: [
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  profileProvider.fetchProfile(profileProvider.profile);
                  Profile fetchedProfile = profileProvider.profile;

                  // Use null-aware operator to handle null values
                  String displayName = "${fetchedProfile.meno} ${fetchedProfile.priezvisko}";

                  return Text(displayName);
                },
              ),
              const SizedBox(width: 10),
              Spacer(),
              IconButton(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Dropdown for selecting laundry location
          DropdownButton<String>(
            value: Provider.of<ProfileProvider>(context, listen: true).profile.miesto,
            onChanged: (String? newValue) {
              setState(() {
                String _selectedLocation = newValue!;
              });
              Profile previousProfile = Provider.of<ProfileProvider>(context, listen: false).profile;
              Profile newProfile = Profile(
                meno: previousProfile.meno,
                priezvisko: previousProfile.priezvisko,
                email: previousProfile.email,
                zostatok: previousProfile.zostatok,
                body: previousProfile.body,
                miesto: newValue!,
                darkMode: previousProfile.darkMode,
              );
              Provider.of<ProfileProvider>(context, listen: false).providerInsertProfile(newProfile);
            },
            items: locations.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          Row(
            children:[
              Text(
                '${Provider.of<ProfileProvider>(context, listen: false).profile.zostatok} CZK   ${Provider.of<ProfileProvider>(context, listen: false).profile.body} bodov',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )
              ),

              const SizedBox(width: 10),
              Spacer(),
              IconButton(
                onPressed: _showAccountHistory,
                icon: const Icon(Icons.search),
              ),
            ]
          ),

          const SizedBox(height: 24),

          TextButton(
            style: TextButton.styleFrom(backgroundColor: Color.fromARGB(255, 223, 223, 223)),
            onPressed: _changeBalance,
            child: const Text('Dobyť peniaze'),
          ),

          const SizedBox(height: 24),

          // Laundry history section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'História',
              style: Theme.of(context).textTheme.headline6,
              ),

              TextButton(
                onPressed: (){
                  for (Reservation reservation in List.from(filteredReservations)){
                    Provider.of<ReservationProvider>(context, listen: false).providerDeleteReservation(reservation);
                  }
                },
                child: const Text('Vymazať')),
            ],
          ),
          
          const Divider(),
          ...filteredReservations
              .map((reservation) => ListTile(
                    leading: Icon(Icons.history, color: Theme.of(context).primaryColor),
                    title: Text("${reservation.machine}",
                        style: (reservation.isPinVerified == 1)
                            ? const TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    Color.fromARGB(255, 51, 213, 135))
                            : null),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text("Miesto: ${reservation.location}"),
                        const SizedBox(height: 5),
                        Text(
                          "Dátum: ${DateFormat('yyyy-MM-dd')
                              .format(reservation.date)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !(reservation.isPinVerified ==
                                        1) &&
                                    DateTime.now()
                                        .isAfter(reservation.date)
                                ? Colors.red
                                : null, // If nearest reservation and time is past, then red
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Čas: ${DateFormat('HH:mm')
                              .format(reservation.date)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !(reservation.isPinVerified ==
                                        1) &&
                                    DateTime.now()
                                        .isAfter(reservation.date)
                                ? Colors.red
                                : null,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          !(reservation.machine == 'Pranie')
                           ? "Cena: 10 CZK"
                           : "Cena: 17 CZK",

                        ),
                      ],
                    ),),)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
