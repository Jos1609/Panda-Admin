// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';


class DeliveryPerson {
  final String id;
  final String name;
  final String phone;
  final bool isAvailable;
  final List<String> activeOrderIds;
  
  DeliveryPerson({
    required this.id,
    required this.name,
    required this.phone,
    this.isAvailable = true,
    this.activeOrderIds = const [],
  });

  factory DeliveryPerson.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DeliveryPerson(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      activeOrderIds: List<String>.from(data['activeOrderIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'isAvailable': isAvailable,
      'activeOrderIds': activeOrderIds,
    };
  }
}