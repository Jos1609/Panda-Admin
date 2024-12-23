// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panda_admin/models/order_item_model.dart';
import 'package:panda_admin/models/status_log_model.dart';

enum OrderStatus {
  pending,    // Pendiente de asignación
  assigned,   // Asignado a repartidor
  inProgress, // En camino
  delivered,  // Entregado
  cancelled   // Cancelado
}

class DeliveryOrder {  // Cambiamos el nombre de Order a DeliveryOrder
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final DateTime orderDate;
  OrderStatus status;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  String? deliveryPersonId;
  String? notes;
  bool isPaid;
  final List<StatusLog> statusHistory;
  
  DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    this.deliveryPersonId,
    this.notes,
    this.isPaid = false,
    required this.statusHistory,
  });

  // Factory constructor para crear desde Firestore
  factory DeliveryOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DeliveryOrder(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      items: (data['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      deliveryPersonId: data['deliveryPersonId'],
      notes: data['notes'],
      isPaid: data['isPaid'] ?? false,
      statusHistory: (data['statusHistory'] as List)
          .map((log) => StatusLog.fromMap(log))
          .toList(),
    );
  }

  // Método para convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      'deliveryPersonId': deliveryPersonId,
      'notes': notes,
      'isPaid': isPaid,
      'statusHistory': statusHistory.map((log) => log.toMap()).toList(),
    };
  }

  // Método para actualizar el estado
  void updateStatus(OrderStatus newStatus, String updatedBy) {
    status = newStatus;
    statusHistory.add(
      StatusLog(
        status: newStatus,
        timestamp: DateTime.now(),
        updatedBy: updatedBy,
      ),
    );
  }
}