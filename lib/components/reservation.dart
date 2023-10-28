import 'dart:html';

class Reservation {
  final int id;
  final String machine;
  final DateTime date;
  final String location;

  const Reservation({
    required this.id,
    required this.machine,
    required this.date,
    required this.location,
  });
}

Map<String, dynamic> toMap(){
  return {
    'id': Id,
    'machine': machine,
    'date': date,
    'location': location
  }
}