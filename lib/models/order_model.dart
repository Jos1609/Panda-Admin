// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panda_admin/models/order_item_model.dart';
import 'package:panda_admin/models/payment_model.dart';
import 'package:panda_admin/models/status_log_model.dart';

enum OrderStatus {
  pending,    // Pendiente de asignación
  assigned,   // Asignado a repartidor
  inProgress, // En camino
  delivered,  // Entregado
  cancelled   // Cancelado
}

class DeliveryOrder {
  final String id;
  final CustomerData customer;
  final DateTime orderDate;
  OrderStatus status;
  final List<OrderItem> items;
  final PaymentData payment;
  final DeliveryData delivery;
  final StoreData store;

  DeliveryOrder({
    required this.id,
    required this.customer,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.payment,
    required this.delivery,
    required this.store,
  });

  factory DeliveryOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return DeliveryOrder(
      id: doc.id,
      customer: CustomerData.fromMap(data['customer'] ?? {}),
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      items: List<OrderItem>.from(
        (data['items'] as List? ?? []).map((item) => OrderItem.fromMap(item)),
      ),
      payment: PaymentData.fromMap(data['payment'] ?? {}),
      delivery: DeliveryData.fromMap(data['delivery'] ?? {}),
      store: StoreData.fromMap(data['store'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer': customer.toMap(),
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toMap()).toList(),
      'payment': payment.toMap(),
      'delivery': delivery.toMap(),
      'store': store.toMap(),
    };
  }

  void updateStatus(OrderStatus newStatus, String updatedBy) {
    status = newStatus;
    delivery.addStatusLog(
      StatusLog(
        status: newStatus,
        timestamp: DateTime.now(),
        updatedBy: updatedBy,
      ),
    );
  }

  double get total => payment.total;
  bool get isPaid => payment.isPaid;
  
  Map<String, dynamic> getUpdateMap(List<String> fields) {
    final Map<String, dynamic> updateData = {};
    
    for (var field in fields) {
      switch (field) {
        case 'status':
          updateData['status'] = status.toString().split('.').last;
          break;
        case 'deliveryPersonId':
          updateData['delivery.deliveryPersonId'] = delivery.deliveryPersonId;
          break;
        case 'isPaid':
          updateData['payment.isPaid'] = payment.isPaid;
          break;
      }
    }
    
    return updateData;
  }
}

class CustomerData {
  final String name;
  final String phone;
  final String address;

  CustomerData({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory CustomerData.fromMap(Map<String, dynamic> map) {
    return CustomerData(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'address': address,
  };
}

class PaymentData {
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final bool isPaid;
  final PaymentMethod? paymentMethod;
  final String? paymentReference;

  PaymentData({
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.isPaid,
    this.paymentMethod,
    this.paymentReference,
  });

  factory PaymentData.fromMap(Map<String, dynamic> map) {
    return PaymentData(
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      isPaid: map['isPaid'] ?? false,
      paymentMethod: map['paymentMethod'] != null 
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString() == 'PaymentMethod.${map['paymentMethod']}',
            )
          : null,
      paymentReference: map['paymentReference'],
    );
  }

  Map<String, dynamic> toMap() => {
    'subtotal': subtotal,
    'tax': tax,
    'deliveryFee': deliveryFee,
    'total': total,
    'isPaid': isPaid,
    'paymentMethod': paymentMethod?.toString().split('.').last,
    'paymentReference': paymentReference,
  };
}

class DeliveryData {
  final String? deliveryPersonId;
  final String? notes;
  final List<StatusLog> statusHistory;

  DeliveryData({
    this.deliveryPersonId,
    this.notes,
    required this.statusHistory,
  });

  factory DeliveryData.fromMap(Map<String, dynamic> map) {
    return DeliveryData(
      deliveryPersonId: map['deliveryPersonId'],
      notes: map['notes'],
      statusHistory: List<StatusLog>.from(
        (map['statusHistory'] as List? ?? [])
            .map((log) => StatusLog.fromMap(log)),
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'deliveryPersonId': deliveryPersonId,
    'notes': notes,
    'statusHistory': statusHistory.map((log) => log.toMap()).toList(),
  };

  void addStatusLog(StatusLog log) {
    statusHistory.add(log);
  }
}

class StoreData {
  final String id;
  final String name;
  final String address;
  final Location location;
  final String? phone;
  final String? instructions; // Instrucciones de recogida

  StoreData({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.phone,
    this.instructions,
  });

  factory StoreData.fromMap(Map<String, dynamic> map) {
    return StoreData(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      location: Location.fromMap(map['location'] ?? {}),
      phone: map['phone'],
      instructions: map['instructions'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'address': address,
    'location': location.toMap(),
    'phone': phone,
    'instructions': instructions,
  };
}

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}