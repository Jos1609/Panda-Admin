class Customer {
  final String name;
  final String phone;
  final String address;

  Customer({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }
}