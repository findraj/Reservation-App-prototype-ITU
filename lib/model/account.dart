class Account {
  int? id = 1;
  int? balance = 0;
  int? price = 0;

  Account({
    this.id,
    required this.balance,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'balance': balance, 'price': price};
  }

  @override
  String toString() {
    return 'Account{id: $id, balance: $balance, price: $price}';
  }
}
