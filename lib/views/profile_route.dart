import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package
import 'package:vyperto/assets/colors.dart';
import 'package:vyperto/model/reservation.dart';
import 'dart:math';

class ProfileRoute extends StatefulWidget {
  const ProfileRoute({super.key});

  @override
  _ProfileRouteState createState() => _ProfileRouteState();
}

class _ProfileRouteState extends State<ProfileRoute> {
  String _selectedLocation = 'PPV'; // Default value for selected location
  List<String> locations = ['PPV', 'Purkyne']; // Available locations
  TextEditingController _codeController = TextEditingController(); // Controller for code input

  // State variables for user information
  String userName = 'Marko';
  String userSurname = 'Olesak';
  String userProfilePicUrl = 'https://avatar.cdnpk.net/23.jpg'; // Replace with actual URL

  // Function to edit user profile
  Future<void> _editProfile() async {
    final ImagePicker _picker = ImagePicker();
    TextEditingController _nameController = TextEditingController(text: userName);
    TextEditingController _surnameController = TextEditingController(text: userSurname);

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
              ElevatedButton(
                onPressed: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      userProfilePicUrl = image.path; // Update the profile picture URL
                    });
                  }
                },
                child: Text('Change Profile Picture'),
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
                });
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
        ),
      );
    }
    return mockReservations;
  }

  @override
  Widget build(BuildContext context) {
    List<Reservation> historyReservations = _generateMockReservations();

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
              CircleAvatar(
                backgroundImage: NetworkImage(userProfilePicUrl),
                radius: 30,
              ),
              const SizedBox(width: 10),
              Text('$userName $userSurname'),
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
            value: _selectedLocation,
            onChanged: (String? newValue) {
              setState(() {
                _selectedLocation = newValue!;
              });
            },
            items: locations.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // TextField for 4-digit code
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: '4-miestny kód',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
          ),

          const SizedBox(height: 24),

          // Button at the bottom
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go back!'),
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
