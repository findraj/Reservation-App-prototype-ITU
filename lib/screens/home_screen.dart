import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/reservation.dart';
import '../components/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _reservationsScreenState createState() => _reservationsScreenState();
}

class _reservationsScreenState extends State<HomeScreen> {
  List<Reservation> _reservations = [];
  @override
  void initState() {
    super.initState();
    _fetchreservations();
  }

  Future<void> _fetchreservations() async {
    final response =
        await http.get(Uri.parse('http://markoshub.com:3000/api/reservations'));
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _reservations = json.map((item) => Reservation.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load reservations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Rezervácie',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: _reservations.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(width: 2)),
                  title: Text(_reservations[index].machine),
                  subtitle: Text("${_reservations[index].date}"),
                  tileColor: primaryColor,
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          ),
        ],
      ),
      backgroundColor: appBarBackgroundColor,
    );
  }
}
