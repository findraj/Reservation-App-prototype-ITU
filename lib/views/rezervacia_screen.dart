/// `RezervaciaScreen` sluzi ako obrazovka pre rezervaciu sluzieb v aplikacii.
///
///  Autor : Filip Botlo xbotlo01
///
/// Tato obrazovka umoznuje uzivatelom vybrat datum a cas pre rezervaciu a
/// poskytuje dalsie moznosti, ako je moznost rezervacie susicky.
///
/// ## Funkcionalita
/// - Umoznuje vyber datumu a casu pomocou `TableCalendar`.
/// - Poskytuje moznost rezervacie susicky.
/// - Spaja sa s poskytovatelmi (providers) pre spracovanie rezervacie.
///
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vyperto/model/account.dart';
import 'package:vyperto/view-model/profile_provider.dart';
import 'package:vyperto/view-model/reservation_provider.dart';
import 'package:vyperto/view-model/account_provider.dart';
import 'package:vyperto/model/reservation.dart';
import 'package:provider/provider.dart';
import 'package:vyperto/views/odmeny_screen.dart';

class RezervaciaScreen extends StatefulWidget {
  final VoidCallback onNavigateToHomeScreen;
  const RezervaciaScreen({Key? key, required this.onNavigateToHomeScreen})
      : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<RezervaciaScreen> {
  ScrollController _scrollController = ScrollController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  bool _wantsDryer = false;
  String? _selectedDormitory;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedDormitory =
        Provider.of<ProfileProvider>(context, listen: false).profile.miesto;

    //nastavi najbliysi volny cas
    String findNearestAvailableTime() {
      DateTime now = DateTime.now();
      DateTime lastTimeSlotToday = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        int.parse(availableTimes.last.split(':')[0]),
        int.parse(availableTimes.last.split(':')[1]),
      );

      if (now.isAfter(lastTimeSlotToday)) {
        return "";
      }

      for (String time in availableTimes) {
        DateTime slotDateTime = DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
          int.parse(time.split(':')[0]),
          int.parse(time.split(':')[1]),
        );

        if (slotDateTime.isAfter(now) &&
            !isTimeSlotReserved(_selectedDay, time)) {
          return time;
        }
      }
      return "";
    }

    _selectedTime = findNearestAvailableTime();

    Future.microtask(() {
      bool editingReservation =
          Provider.of<ProfileProvider>(context, listen: false)
              .isEditingReservation;
      bool isDryingMachine = editingReservation &&
          Provider.of<ProfileProvider>(context, listen: false)
                  .currentReservation
                  .machine ==
              "Pranie a sušenie";

      setState(() {
        _wantsDryer = isDryingMachine;
        _selectedDay = DateTime.now();
        _selectedTime = findNearestAvailableTime();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          int selectedIndex = availableTimes.indexOf(_selectedTime!);
          if (selectedIndex != -1) {
            double offset = selectedIndex * 70.0;
            _scrollController.animateTo(
              offset - MediaQuery.of(context).size.width / 2 + 35,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // pocita v zavislosti na tom ci sme si vzbrali aj susenie
  int calculateCost() {
    bool editingReservation =
        Provider.of<ProfileProvider>(context, listen: false)
            .isEditingReservation;
    bool includesDrying = editingReservation &&
        Provider.of<ProfileProvider>(context, listen: false)
                .currentReservation
                .machine ==
            "Pranie a sušenie";
    //mozne kombinacie reyervovanych strojov a ci editujeme alebo robime novu
    if (editingReservation && includesDrying && _wantsDryer) {
      return 0;
    } else if (editingReservation && includesDrying && !_wantsDryer) {
      return COST_WASHING - COST_WASHING_DRYING;
    } else if (editingReservation && !includesDrying && _wantsDryer) {
      return COST_WASHING_DRYING - COST_WASHING;
    } else if (editingReservation && !includesDrying && !_wantsDryer) {
      return 0;
    } else {
      return _wantsDryer ? COST_WASHING_DRYING : COST_WASHING;
    }
  }

  //casy do 7 do 20, potom uy neplatia rezervacie
  List<String> availableTimes = List<String>.generate(
      14, (index) => "${(index + 7).toString().padLeft(2, '0')}:00");

  //kontroluje ci uz to je rezervovane aj v zavislosti na intraku
  bool isTimeSlotReserved(DateTime? selectedDay, String timeSlot) {
    if (selectedDay == null) return false;

    final String selectedDormitory =
        Provider.of<ProfileProvider>(context, listen: false).profile.miesto;

    final reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);
    List<Reservation> userReservations = reservationProvider.reservationsList;

    DateTime slotDateTime = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1]),
    );

    return userReservations.any((reservation) {
      return reservation.date.isAtSameMomentAs(slotDateTime) &&
          reservation.location == selectedDormitory;
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
                title: const Text("Rezervovať aj sušičku"),
                value: _wantsDryer,
                onChanged: (bool? value) {
                  setState(() {
                    _wantsDryer = value ?? false;
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
                      Provider.of<ProfileProvider>(context, listen: false)
                              .isUsingReward
                          ? 'Cena: ${calculateCost()} bodov'
                          : 'Cena: ${calculateCost()} korún',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          Container(
            height: 70,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: availableTimes.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 70,
                  alignment: Alignment.center,
                  child: _buildTimeButton(
                      availableTimes[index]), //spravi rad casov
                );
              },
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);
              final reservationProvider =
                  Provider.of<ReservationProvider>(context, listen: false);
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
                String machineType =
                    _wantsDryer ? "Pranie a sušenie" : "Pranie";
                int cost = calculateCost();
                int bod = _wantsDryer ? 2 : 1;
                if (profileProvider.isEditingReservation == true) {
                  Reservation currentReservation =
                      profileProvider.currentReservation;
                  currentReservation.machine = machineType;
                  currentReservation.date = dateTime;
                  currentReservation.location = location;
                  reservationProvider
                      .providerUpdateReservation(currentReservation)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Rezervácia úspešne upravená')),
                    );
                    widget.onNavigateToHomeScreen();
                  }).catchError((error) {
                    print('Chyba pri upravovani rezervacie: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Chyba pri upravovaní rezervácie')),
                    );
                  });
                  return;
                }
                if (dateTime.isBefore(_focusedDay)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Nemôžete rezervovať čas v minulosti')),
                  );
                  return;
                } else {
                  Reservation newReservation = Reservation(
                    machine: machineType,
                    date: dateTime,
                    location: location,
                    isPinVerified: 0,
                    isExpired: 0,
                    wasFree: 0,
                  );

                  if (profileProvider.isUsingReward) {
                    newReservation.wasFree = 1;
                  }
                  if (profileProvider.isEditingReservation == false) {
                    if (profileProvider.isUsingReward) {
                      if (profile.body >= cost) {
                        profileProvider.updateProfilePoints(profile,
                            -cost); //odobere z bodov pri vyuziti odmeny
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Nedostatok vernostných bodov')),
                        );
                        return;
                      }
                    } else {
                      if (profile.zostatok < cost) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Nedostatok kreditov na účte')),
                        );
                        return;
                      } else {
                        profileProvider.updateProfileBalance(
                            profile, -cost); //odobere z balancu pri rezervacii
                        Account account = Account(
                          balance: Provider.of<ProfileProvider>(context,
                                  listen: false)
                              .profile
                              .zostatok,
                          price: -cost,
                        );
                        Provider.of<AccountProvider>(context, listen: false)
                            .providerInsertAccount(account);
                      }
                    }
                  }
                  reservationProvider
                      .providerInsertReservation(newReservation)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Rezervácia úspešne bola uložená')),
                    );
                    profileProvider.updateProfilePoints(profile, bod);
                    widget.onNavigateToHomeScreen();
                  }).catchError((error) {
                    print('Chyba pri ukladani rezervacie: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Chyba pri ukladaní rezervácie')),
                    );
                  });
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vyberte deň a čas rezervácie')),
                );
              }
            },
            child: const Text('Potvrdiť'),
          ),
          const SizedBox(height: 5),
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
