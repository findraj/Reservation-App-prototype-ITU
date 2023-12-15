import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/model/reservation.dart';
import 'package:provider/provider.dart';
import 'package:vyperto/views/odmeny_screen.dart';

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

  int calculateCost() {
    return _wantsDryer ? 17 : 10;
  }

  List<String> availableTimes = List<String>.generate(14, (index) => "${(index + 7).toString().padLeft(2, '0')}:00");

  bool isTimeSlotReserved(DateTime? selectedDay, String timeSlot) {
    if (selectedDay == null) return false;

    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    List<Reservation> userReservations = reservationProvider.reservationsList;

    DateTime slotDateTime = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1]),
    );

    return userReservations.any((reservation) {
      return reservation.date.isAtSameMomentAs(slotDateTime);
    });
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: (Provider.of<ProfileProvider>(context, listen: false).isEditingReservation && Provider.of<ProfileProvider>(context, listen: false).currentReservation.machine == "Pranie a sušenie") ? const Text("Sušenie už máš pridané") : const Text("Rezervovať aj sušičku"),
                value: (Provider.of<ProfileProvider>(context, listen: false).isEditingReservation && Provider.of<ProfileProvider>(context, listen: false).currentReservation.machine == "Pranie a sušenie") ? true : _wantsDryer,
                enabled: (Provider.of<ProfileProvider>(context, listen: false).isEditingReservation && Provider.of<ProfileProvider>(context, listen: false).currentReservation.machine == "Pranie a sušenie") ? false : true,
                onChanged: (bool? value) {
                  setState(() {
                    _wantsDryer = value!;
                  });
                },
                secondary: const Icon(Icons.local_laundry_service),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      Provider.of<ProfileProvider>(context, listen: false).isEditingReservation ? 'Cena: ${calculateCost() - 10} kreditov' : 'Cena: ${calculateCost()} kreditov',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableTimes.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 70,
                  alignment: Alignment.center,
                  child: _buildTimeButton(availableTimes[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 35.0),
          ElevatedButton(
            onPressed: () {
              final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
              final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
              final profile = profileProvider.profile;
              if (_selectedDay != null && _selectedTime != null) {
                DateTime dateTime = DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                  int.parse(_selectedTime!.split(':')[0]),
                  int.parse(_selectedTime!.split(':')[1]),
                );
                String location = profile.miesto;
                String machineType = _wantsDryer ? "Pranie a sušenie" : "Pranie";
                int cost = _wantsDryer ? COST_WASHING_DRYING : COST_WASHING;

                if (profileProvider.isEditingReservation == false) {
                  if (profileProvider.isUsingReward) {
                    if (profile.body >= cost) {
                      profileProvider.updateProfilePoints(profile, -cost);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nedostatok vernostných bodov')),
                      );
                      return;
                    }
                  } else {
                    if (profile.zostatok < cost) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nedostatok kreditov na účte')),
                      );
                      return;
                    }
                    profileProvider.updateProfileBalance(profile, -cost);
                  }
                } else {
                  cost -= COST_WASHING;
                  if (cost != 0) {
                    profileProvider.updateProfileBalance(profile, -cost);
                  }
                }

                if (profileProvider.isEditingReservation == true) {
                  Reservation currentReservation = profileProvider.currentReservation;
                  currentReservation.machine = machineType;
                  currentReservation.date = dateTime;
                  currentReservation.location = location;
                  reservationProvider.providerUpdateReservation(currentReservation).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rezervácia úspešne upravená')),
                    );
                  }).catchError((error) {
                    print('Chyba pri upravovani rezervacie: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chyba pri upravovaní rezervácie')),
                    );
                  });
                  return;
                }

                Reservation newReservation = Reservation(
                  machine: machineType,
                  date: dateTime,
                  location: location,
                  isPinVerified: 0,
                  isExpired: 0,
                );

                reservationProvider.providerInsertReservation(newReservation).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rezervácia úspešne bola uložená')),
                  );
                }).catchError((error) {
                  print('Chyba pri ukladani rezervacie: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chyba pri ukladaní rezervácie')),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vyberte deň a čas rezervácie')),
                );
              }
            },
            child: const Text('Potvrdiť'),
          ),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }

  ElevatedButton _buildTimeButton(String time) {
    bool isReserved = isTimeSlotReserved(_selectedDay, time);

    return ElevatedButton(
      onPressed: isReserved
          ? null
          : () {
              setState(() {
                _selectedTime = time;
              });
            },
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (isReserved) {
              return Colors.red;
            } else if (_selectedTime == time) {
              return Theme.of(context).primaryColor;
            }
            return Colors.grey[300]!;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (isReserved || (_selectedTime == time)) {
              return Colors.white;
            }
            return Colors.black;
          },
        ),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
