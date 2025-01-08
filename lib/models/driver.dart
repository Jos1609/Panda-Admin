// lib/models/driver.dart

class Driver {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final String? photoUrl;
  final DriverStatus status;
  final double rating;
  final int totalDeliveries;
  final double averageDeliveryTime;
  final double onTimeDeliveryPercentage;

  Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    this.photoUrl,
    required this.status,
    required this.rating,
    required this.totalDeliveries,
    required this.averageDeliveryTime,
    required this.onTimeDeliveryPercentage,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      photoUrl: json['photoUrl'],
      status: DriverStatus.values[json['status']],
      rating: json['rating'].toDouble(),
      totalDeliveries: json['totalDeliveries'],
      averageDeliveryTime: json['averageDeliveryTime'].toDouble(),
      onTimeDeliveryPercentage: json['onTimeDeliveryPercentage'].toDouble(),
    );
  }
  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'email': email,
    'address': address,
    'status': status.index,
    'rating': rating,
    'totalDeliveries': totalDeliveries,
    'averageDeliveryTime': averageDeliveryTime,
    'onTimeDeliveryPercentage': onTimeDeliveryPercentage,
  };
}
}

enum DriverStatus {
  available,
  busy,
  outOfService
}