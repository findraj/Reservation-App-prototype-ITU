class Reservation {
  final int id;
  final String machine;
  final DateTime date;
  final String location;

  Reservation({
    required this.id,
    required this.machine,
    required this.date,
    required this.location,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      machine: json['machine'],
      date: DateTime.parse(json['date']),
      location: json['location'],
    );
  }
}
