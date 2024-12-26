import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/orders/orders_list_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/orders/create_order_screen.dart';
import '../screens/login_screen.dart';

class Routes {
  // Rutas principales
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  
  // Rutas de pedidos
  static const String orders = '/orders';
  static const String orderDetail = '/orders/detail';
  static const String createOrder = '/orders/create';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      dashboard: (context) => const DashboardScreen(),
      orders: (context) => const OrdersListScreen(),
      orderDetail: (context) {
        final String orderId = ModalRoute.of(context)!.settings.arguments as String;
        return OrderDetailScreen(orderId: orderId);
      },
      createOrder: (context) => const CreateOrderScreen(),
    };
  }
}