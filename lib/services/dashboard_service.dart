import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_stats.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DashboardStats> getDashboardStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Convierte las fechas a Timestamps para Firestore
      final Timestamp startTimestamp = Timestamp.fromDate(startDate);
      final Timestamp endTimestamp = Timestamp.fromDate(endDate);

      // Realiza la consulta con filtros de rango
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('orderDate', isGreaterThanOrEqualTo: startTimestamp)
          .where('orderDate', isLessThanOrEqualTo: endTimestamp)
          .get();

      // Calcular la suma de los totales
      double totalRevenue = 0.0;
      for (var doc in ordersSnapshot.docs) {
        final orderTotal = doc.data()['deliveryFee']; // O el campo total si corresponde
        if (orderTotal != null && orderTotal is num) {
          totalRevenue += orderTotal.toDouble();
        }
      }

      return DashboardStats(
        totalOrders: ordersSnapshot.docs.length,
        totalRevenue: totalRevenue,
        registeredCustomers: 0, // Obtener de Firestore
        activeDrivers: 0, // Obtener de Firestore
        averageDeliveryTime: 0.0, // Calcular desde los datos
        ordersByStatus: {}, // Calcular desde los datos
        topProducts: [], // Calcular desde los datos
      );
    } catch (e) {
      throw Exception('Error al obtener estadísticas del dashboard: $e');
    }
  }
}
