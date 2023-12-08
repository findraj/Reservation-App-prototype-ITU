class Reservation {
  final int id;
  final String machine;
  final DateTime date;
  final String location;
  int isPinVerified = 0;

  Reservation({
    required this.id,
    required this.machine,
    required this.date,
    required this.location,
    required this.isPinVerified,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'machine': machine, 'date': date.millisecondsSinceEpoch, 'location': location, 'isPinVerified': isPinVerified};
  }

  @override
  String toString() {
    return 'Reservation{id: $id, machine: $machine, date: $date, location: $location, isPinVerified: $isPinVerified}';
  }
}
