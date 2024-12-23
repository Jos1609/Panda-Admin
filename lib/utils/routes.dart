import 'package:flutter/material.dart';
import '../screens/orders/orders_list_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/orders/create_order_screen.dart';

class Routes {
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';
  static const String createOrder = '/create-order';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      orders: (context) => const OrdersListScreen(),
      orderDetail: (context) => OrderDetailScreen(
        orderId: ModalRoute.of(context)!.settings.arguments as String,
      ),
      createOrder: (context) => const CreateOrderScreen(),
    };
  }
}