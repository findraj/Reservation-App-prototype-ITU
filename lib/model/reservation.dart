class Reservation {
  int? id;
  String machine;
  DateTime date;
  String location;
  int isPinVerified = 0;
  int isExpired = 0;
  int wasFree = 0;

  Reservation({
    this.id,
    required this.machine,
    required this.date,
    required this.location,
    required this.isPinVerified,
    required this.isExpired,
    required this.wasFree,
  });

  Map<String, dynamic> toMap() {
    return {
      'machine': machine,
      'date': date.millisecondsSinceEpoch,
      'location': location,
      'isPinVerified': isPinVerified,
      'isExpired': isExpired,
      'wasFree': wasFree,
    };
  }

  @override
  String toString() {
    return 'Reservation{id: $id, machine: $machine, date: $date, location: $location, isPinVerified: $isPinVerified, isExpired: $isExpired, wasFree: $wasFree}';
  }
}
