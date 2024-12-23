import 'package:panda_admin/models/order_model.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';


class StatusLog {
  final OrderStatus status;
  final DateTime timestamp;
  final String updatedBy;
  
  StatusLog({
    required this.status,
    required this.timestamp,
    required this.updatedBy,
  });

  factory StatusLog.fromMap(Map<String, dynamic> map) {
    return StatusLog(
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.pending,
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      updatedBy: map['updatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedBy': updatedBy,
    };
  }
}