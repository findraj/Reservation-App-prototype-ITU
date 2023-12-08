import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

  List<String> availableTimes = [
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00"
  ];

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
              // firstDay: DateTime.utc(2010, 10, 16),
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
              //
              print('Date: $_selectedDay, Time: $_selectedTime');
            },
            child: const Text('Potvrdiť'),
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
            if (states.contains(MaterialState.pressed) ||
                (_selectedTime == time)) {
              return Theme.of(context).primaryColor;
            }
            return Colors.grey[300]!;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.pressed) ||
                (_selectedTime == time)) {
              return Colors.white;
            }
            return Colors.black;
          },
        ),
      ),
    );
  }
}
