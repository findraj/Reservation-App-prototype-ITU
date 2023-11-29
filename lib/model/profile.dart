class Profile {
  final int id = 1;
  String meno = "example";
  String email = "example@example.com";
  int zostatok = 1000;
  int body = 5;

  Map<String, dynamic> toMap() {
    return {'meno': meno, 'email': email, 'zostatok': zostatok, 'body': body};
  }

  @override
  String toString() {
    return 'Profile{meno: $meno, email: $email, zostatok: $zostatok, body: $body}';
  }
}