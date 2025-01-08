// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panda_admin/models/payment_model.dart';
import '../models/order_model.dart';
import '../utils/app_exception.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  // Stream de pedidos con paginación y filtros
  Stream<List<DeliveryOrder>> getOrders({
    int limit = 100,
    OrderStatus? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? deliveryPersonId,
  }) {
    Query query = _firestore
        .collection(_collection)
        .orderBy('orderDate', descending: true)
        .limit(limit);

    // Aplicar filtros
    if (statusFilter != null) {
      query = query.where('status',
          isEqualTo: statusFilter.toString().split('.').last);
    }

    if (startDate != null) {
      query = query.where('orderDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('orderDate',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    if (deliveryPersonId != null) {
      query = query.where('deliveryPersonId', isEqualTo: deliveryPersonId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => DeliveryOrder.fromFirestore(doc)).toList());
  }

  // Crear nuevo pedido
  Future<String> createOrder(DeliveryOrder order) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw AppException('Error al crear el pedido: $e');
    }
  }

  // Actualizar estado del pedido
  Future<void> updateOrderStatus(
      String orderId, OrderStatus newStatus, String updatedBy) async {
    try {
      final orderRef = _firestore.collection(_collection).doc(orderId);

      await _firestore.runTransaction((transaction) async {
        final orderDoc = await transaction.get(orderRef);
        final order = DeliveryOrder.fromFirestore(orderDoc);

        order.updateStatus(newStatus, updatedBy);

        transaction.update(orderRef, {
          'status': newStatus.toString().split('.').last,
          'statusHistory':
              order.statusHistory.map((log) => log.toMap()).toList(),
        });
      });
    } catch (e) {
      throw AppException('Error al actualizar el estado del pedido: $e');
    }
  }

  // Asignar repartidor
  Future<void> assignDeliveryPerson(
      String orderId, String deliveryPersonId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'deliveryPersonId': deliveryPersonId,
        'status': OrderStatus.assigned.toString().split('.').last, // Cambia automáticamente el estado a asignado
      });
    } catch (e) {
      throw AppException('Error al asignar repartidor: $e');
    }
  }

  // Actualizar notas del pedido
  Future<void> updateOrderNotes(String orderId, String notes) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'notes': notes,
      });
    } catch (e) {
      throw AppException('Error al actualizar notas: $e');
    }
  }

  // Actualizar estado de pago
  Future<void> updatePaymentStatus(String orderId, bool isPaid) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'isPaid': isPaid,
      });
    } catch (e) {
      throw AppException('Error al actualizar estado de pago: $e');
    }
  }

  // Obtener estadísticas de pedidos
  Future<Map<String, dynamic>> getOrderStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('orderDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final orders = querySnapshot.docs
          .map((doc) => DeliveryOrder.fromFirestore(doc))
          .toList();

      return {
        'totalOrders': orders.length,
        // ignore: avoid_types_as_parameter_names
        'totalRevenue': orders.fold(0.0, (sum, order) => sum + order.total),
        'avgDeliveryTime':
            _calculateAverageDeliveryTime(orders.cast<DeliveryOrder>()),
        'cancelRate': _calculateCancelRate(orders.cast<DeliveryOrder>()),
        'statusDistribution':
            _getStatusDistribution(orders.cast<DeliveryOrder>()),
      };
    } catch (e) {
      throw AppException('Error al obtener estadísticas: $e');
    }
  }

  double _calculateAverageDeliveryTime(List<DeliveryOrder> orders) {
    final deliveredOrders =
        orders.where((order) => order.status == OrderStatus.delivered);
    if (deliveredOrders.isEmpty) return 0.0;

    final totalMinutes = deliveredOrders.map((order) {
      final startLog = order.statusHistory.first;
      final endLog = order.statusHistory.last;
      return endLog.timestamp.difference(startLog.timestamp).inMinutes;
    }).reduce((a, b) => a + b);

    return totalMinutes / deliveredOrders.length;
  }

  double _calculateCancelRate(List<DeliveryOrder> orders) {
    if (orders.isEmpty) return 0.0;
    final cancelledOrders =
        orders.where((order) => order.status == OrderStatus.cancelled);
    return (cancelledOrders.length / orders.length) * 100;
  }

  Map<String, int> _getStatusDistribution(List<DeliveryOrder> orders) {
    final distribution = <String, int>{};
    for (final status in OrderStatus.values) {
      distribution[status.toString()] =
          orders.where((order) => order.status == status).length;
    }
    return distribution;
  }

  // Agregar este método a la clase OrderService
  Future<void> updatePaymentInfo(
    String orderId,
    PaymentMethod method,
    String? reference,
    bool isPaid,
  ) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'paymentMethod': method.toString().split('.').last,
        'paymentReference': reference,
        'isPaid': isPaid,
      });
    } catch (e) {
      throw AppException('Error al actualizar información de pago: $e');
    }
  }

  Stream<List<DeliveryOrder>> getDriverOrders(String driverId) {
    try {
      // Obtén la referencia a la colección de órdenes
      final CollectionReference ordersCollection =
          FirebaseFirestore.instance.collection('orders');

      // Devuelve un Stream que escucha cambios en las órdenes asignadas al repartidor
      return ordersCollection
          .where('deliveryPersonId', isEqualTo: driverId)
          .snapshots()
          .map((snapshot) {
        // Convierte cada documento en un DeliveryOrder
        return snapshot.docs
            .map((doc) => DeliveryOrder.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error al obtener las órdenes del repartidor: $e');
      return const Stream.empty();
    }
  }
}
