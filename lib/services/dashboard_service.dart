// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_stats.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DashboardStats> getDashboardStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Implementar lógica para obtener estadísticas de Firestore
      // Este es un ejemplo simplificado
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('orderDate', isGreaterThanOrEqualTo: startDate)
          .where('orderDate', isLessThanOrEqualTo: endDate)
          .get();

      // Calcular la suma de los totales
      double totalRevenue = 0.0;
      for (var doc in ordersSnapshot.docs) {
        // Asegúrate de que el campo 'total' existe y es de tipo numérico
        final orderTotal = doc.data()['deliveryFee'];
        if (orderTotal != null && orderTotal is num) {
          totalRevenue += orderTotal.toDouble();
        }
      }

      return DashboardStats(
        totalOrders: ordersSnapshot.docs.length,
        totalRevenue: totalRevenue, // Calcular desde los datos
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
