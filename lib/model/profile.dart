/// `profile` model pre uchovanie informacii o uzivatelovi
///
///  Autor: Marko Olešák xolesa00
///
/// Model uzivatela, ktory obsahuje vsetky potrebne informacie o uzivatelovi.
/// Obsahuje aj metody na prevod z a do mapy, ktore sa pouzivaju pri praci s databazou.
///
/// ## Funkcionalita
/// - Uchovava informacie o uzivatelovi.
/// - Metody na prevod z a do mapy.
///
class Profile {
  final int id = 1;
  String meno;
  String priezvisko;
  String email;
  int zostatok;
  int body;
  String miesto;

  Profile({
    required this.meno,
    required this.priezvisko,
    required this.email,
    required this.zostatok,
    required this.body,
    required this.miesto,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'meno': meno, 'priezvisko' : priezvisko, 'email': email, 'zostatok': zostatok, 'body': body, 'miesto': miesto};
  }

  @override
  String toString() {
    return 'Profile{id: $id, meno: $meno, priezvisko: $priezvisko, email: $email, zostatok: $zostatok, body: $body, miesto: $miesto}';
  }
}
