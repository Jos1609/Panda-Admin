// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panda_admin/models/order_model.dart';
import '../models/payment_model.dart';
import '../utils/app_exception.dart';

class OrderService {
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 final String _collection = 'orders';

 // Stream de pedidos con filtros
 Stream<List<DeliveryOrder>> getOrders({
   int limit = 20,
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
     query = query.where('delivery.deliveryPersonId', 
       isEqualTo: deliveryPersonId);
   }

   return query.snapshots().map((snapshot) =>
       snapshot.docs.map((doc) => DeliveryOrder.fromFirestore(doc)).toList());
 }

 // CRUD Operations
 Future<String> createOrder(DeliveryOrder order) async {
   try {
     final docRef = await _firestore
       .collection(_collection)
       .add(order.toMap());
     return docRef.id;
   } catch (e) {
     throw AppException('Error al crear el pedido: $e');
   }
 }

 Future<void> updateOrderStatus(
   String orderId, 
   OrderStatus newStatus, 
   String updatedBy
 ) async {
   try {
     await _firestore.runTransaction((transaction) async {
       final orderRef = _firestore.collection(_collection).doc(orderId);
       final orderDoc = await transaction.get(orderRef);
       final order = DeliveryOrder.fromFirestore(orderDoc);

       order.updateStatus(newStatus, updatedBy);

       transaction.update(orderRef, {
         'status': newStatus.toString().split('.').last,
         'delivery.statusHistory': order.delivery.statusHistory
           .map((log) => log.toMap()).toList(),
       });
     });
   } catch (e) {
     throw AppException('Error al actualizar estado: $e');
   }
 }

 Future<void> assignDeliveryPerson(
   String orderId, 
   String deliveryPersonId
 ) async {
   try {
     await _firestore.collection(_collection).doc(orderId).update({
       'delivery.deliveryPersonId': deliveryPersonId,
       'status': OrderStatus.assigned.toString().split('.').last,
     });
   } catch (e) {
     throw AppException('Error al asignar repartidor: $e'); 
   }
 }

 Future<void> updatePaymentInfo(
   String orderId,
   PaymentMethod method, 
   String? reference,
   bool isPaid,
 ) async {
   try {
     await _firestore.collection(_collection).doc(orderId).update({
       'payment.method': method.toString().split('.').last,
       'payment.reference': reference,
       'payment.isPaid': isPaid,
     });
   } catch (e) {
     throw AppException('Error al actualizar pago: $e');
   }
 }

 // Estadísticas
 Future<Map<String, dynamic>> getOrderStats(
   DateTime startDate, 
   DateTime endDate,
 ) async {
   try {
     final querySnapshot = await _firestore
         .collection(_collection)
         .where('orderDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
         .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
         .get();

     final orders = querySnapshot.docs
         .map((doc) => DeliveryOrder.fromFirestore(doc))
         .toList();

     return {
       'totalOrders': orders.length,
       'totalRevenue': _calculateTotalRevenue(orders),
       'avgDeliveryTime': _calculateAverageDeliveryTime(orders),
       'cancelRate': _calculateCancelRate(orders),
       'statusDistribution': _getStatusDistribution(orders),
     };
   } catch (e) {
     throw AppException('Error al obtener estadísticas: $e');
   }
 }

 // Stream de pedidos por repartidor
 Stream<List<DeliveryOrder>> getDriverOrders(String driverId) {
   try {
     return _firestore
         .collection(_collection)
         .where('delivery.deliveryPersonId', isEqualTo: driverId)
         .snapshots()
         .map((snapshot) => snapshot.docs
             .map((doc) => DeliveryOrder.fromFirestore(doc))
             .toList());
   } catch (e) {
     print('Error al obtener órdenes del repartidor: $e');
     return const Stream.empty();
   }
 }

 // Métodos privados para estadísticas
 double _calculateTotalRevenue(List<DeliveryOrder> orders) {
   // ignore: avoid_types_as_parameter_names
   return orders.fold(0.0, (sum, order) => sum + order.payment.total);
 }

 double _calculateAverageDeliveryTime(List<DeliveryOrder> orders) {
   final deliveredOrders = orders.where(
     (order) => order.status == OrderStatus.delivered);
     
   if (deliveredOrders.isEmpty) return 0.0;

   final totalMinutes = deliveredOrders.map((order) {
     final startLog = order.delivery.statusHistory.first;
     final endLog = order.delivery.statusHistory.last;
     return endLog.timestamp.difference(startLog.timestamp).inMinutes;
   }).reduce((a, b) => a + b);

   return totalMinutes / deliveredOrders.length;
 }

 double _calculateCancelRate(List<DeliveryOrder> orders) {
   if (orders.isEmpty) return 0.0;
   final cancelledOrders = orders.where(
     (order) => order.status == OrderStatus.cancelled);
   return (cancelledOrders.length / orders.length) * 100;
 }

 Map<String, int> _getStatusDistribution(List<DeliveryOrder> orders) {
   final distribution = <String, int>{};
   for (final status in OrderStatus.values) {
     distribution[status.toString()] = orders
       .where((order) => order.status == status)
       .length;
   }
   return distribution;
 }
}