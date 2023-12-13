import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vyperto/assets/colors.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/model/reservation.dart';
import 'package:vyperto/model/profile.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vyperto/assets/profile_info.dart';

class RezervaciaScreen extends StatefulWidget {
  const RezervaciaScreen({Key? key}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<RezervaciaScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  bool _wantsDryer = false;

  List<String> availableTimes = ["10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 215, 215, 215),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(104, 158, 158, 158),
                  blurRadius: 8,
                  offset: Offset(4, 8),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedTime = null;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          CheckboxListTile(
            title: Text("Pridať aj sušičku"),
            value: _wantsDryer,
            onChanged: (bool? value) {
              setState(() {
                _wantsDryer = value!;
              });
            },
            secondary: Icon(Icons.local_laundry_service),
          ),
          Wrap(
            spacing: 10.0,
            children: availableTimes.getRange(0, 4).map((time) {
              return _buildTimeButton(time);
            }).toList(),
          ),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 10.0,
            children: availableTimes.getRange(4, 8).map((time) {
              return _buildTimeButton(time);
            }).toList(),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              if (_selectedDay != null && _selectedTime != null) {
                DateTime dateTime = DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                  int.parse(_selectedTime!.split(':')[0]),
                  int.parse(_selectedTime!.split(':')[1]),
                );

                final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                final profile = profileProvider.profile;

                String location = profile.miesto;

                String machineType = _wantsDryer ? "Pranie a sušenie" : "Pranie";
                int cost = _wantsDryer ? 17 : 10;

                if (profile.zostatok < cost) {
                  // If the user doesn't have enough balance, show a notification and exit
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('Nedostatok zostatku na účte!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // Create new reservation
                Reservation newReservation = Reservation(
                  machine: machineType,
                  date: dateTime,
                  location: location,
                  isPinVerified: 0,
                  isExpired: 0,
                );

                // Save the reservation and update the profile balance
                final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
                reservationProvider.providerInsertReservation(newReservation).then((_) {
                  // Update user's balance
                  profileProvider.updateProfileBalance(profile, -cost);

                  // Show success notification
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.greenAccent,
                      content: Text('Rezervácia úspešne uložená!'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Debug information
                  print('Rezervacia ulozena: Datum: ${_selectedDay.toString()}, Cas: $_selectedTime');
                }).catchError((error) {
                  // Handle errors during reservation saving
                  print('Chyba pri ukladani rezervacie: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chyba pri ukladani rezervacie')),
                  );
                });
              } else {
                print('Vyberte prosim datum a cas');
              }
            },
            child: const Text('Potvrdit'),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  ElevatedButton _buildTimeButton(String time) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTime = time;
        });
      },
      child: Text(time),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.pressed) || (_selectedTime == time)) {
              return Theme.of(context).primaryColor;
            }
            return Colors.grey[300]!;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.pressed) || (_selectedTime == time)) {
              return Colors.white;
            }
            return Colors.black;
          },
        ),
      ),
    );
  }
}
