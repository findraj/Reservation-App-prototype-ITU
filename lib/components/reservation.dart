
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

  Map<String, dynamic> toMap() {
    return {'id': id, 'machine': machine, 'date': date.millisecondsSinceEpoch, 'location': location};
  }

    @override
  String toString() {
    return 'Reservation{id: $id, machine: $machine, date: $date, location: $location}';
  }
}
