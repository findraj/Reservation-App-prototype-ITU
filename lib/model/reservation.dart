class Reservation {
  int? id;
  String machine;
  DateTime date;
  String location;
  int isPinVerified = 0;
  int isExpired = 0;

  Reservation({
    this.id,
    required this.machine,
    required this.date,
    required this.location,
    required this.isPinVerified,
    required this.isExpired,
  });

  Map<String, dynamic> toMap() {
    return {
      'machine': machine,
      'date': date.millisecondsSinceEpoch,
      'location': location,
      'isPinVerified': isPinVerified,
      'isExpired': isExpired,
    };
  }

  @override
  String toString() {
    return 'Reservation{id: $id, machine: $machine, date: $date, location: $location, isPinVerified: $isPinVerified, isExpired: $isExpired}';
  }
}
