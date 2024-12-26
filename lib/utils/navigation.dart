import 'package:flutter/material.dart';
import 'package:panda_admin/screens/orders/create_order_screen.dart';
import '../screens/orders/order_detail_screen.dart';

class AppNavigation {
  static void goToOrderDetail(BuildContext context, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: orderId),
      ),
    );
  }

  static void goToCreateOrder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOrderScreen(),
      ),
    );
  }

  // Función para volver atrás
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}