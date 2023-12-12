import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vyperto/assets/colors.dart';
import 'package:vyperto/model/reservation.dart';
import 'package:vyperto/model/profile.dart';
import 'dart:math';

import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/view-model/reservation_provider.dart';

class ProfileRoute extends StatefulWidget {
  const ProfileRoute({super.key});

  @override
  _ProfileRouteState createState() => _ProfileRouteState();
}

class _ProfileRouteState extends State<ProfileRoute> {
  String _selectedLocation = 'Koleje pod Palackého vrchem'; // Default value for selected location
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

  // Function to edit user profile
  Future<void> _editProfile() async {
    TextEditingController _nameController = TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).profile.meno);
    TextEditingController _surnameController = TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).profile.priezvisko);
    TextEditingController _emailController = TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).profile.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
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
              child: Text('Cancel'),
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
              child: Text('Save Changes'),
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
        ),
      );
    }
    return mockReservations;
  }

  @override
  Widget build(BuildContext context) {
    List<Reservation> historyReservations = Provider.of<ReservationProvider>(context, listen: true).reservationsList;

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
                  String displayName = "${fetchedProfile.meno ?? ''} ${fetchedProfile.priezvisko ?? ''}";

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
                _selectedLocation = newValue!;
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

          TextButton(
            style: TextButton.styleFrom(backgroundColor: Color.fromARGB(255, 223, 223, 223)),
            onPressed: _changeBalance,
            child: Text('Dobyť peniaze'),
          ),

          const SizedBox(height: 24),

          // Laundry history section
          Text(
            'História Prania',
            style: Theme.of(context).textTheme.headline6,
          ),
          const Divider(),
          ...historyReservations
              .map((reservation) => ListTile(
                    title: Text('Rezervácia: ${reservation.machine}, Dátum: ${reservation.date}, Miesto: ${reservation.location}'),
                    leading: Icon(Icons.history, color: Theme.of(context).primaryColor),
                  ))
              .toList(),
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
