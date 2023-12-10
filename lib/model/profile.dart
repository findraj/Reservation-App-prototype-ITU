class Profile {
  final int id = 1;
  String meno;
  String priezvisko;
  String email;
  int zostatok;
  int body;
  String miesto;
  int darkMode = 0;

  Profile({
    required this.meno,
    required this.priezvisko,
    required this.email,
    required this.zostatok,
    required this.body,
    required this.miesto,
    required this.darkMode,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'meno': meno, 'priezvisko' : priezvisko, 'email': email, 'zostatok': zostatok, 'body': body, 'miesto': miesto, 'darkMode': darkMode};
  }

  @override
  String toString() {
    return 'Profile{id: $id, meno: $meno, priezvisko: $priezvisko, email: $email, zostatok: $zostatok, body: $body, miesto: $miesto, darkMode: $darkMode}';
  }
}
