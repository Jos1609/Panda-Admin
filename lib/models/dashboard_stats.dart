class DashboardStats {
  final int totalOrders;
  final double totalRevenue;
  final int registeredCustomers;
  final int activeDrivers;
  final double averageDeliveryTime;
  final Map<String, int> ordersByStatus;
  final List<TopProduct> topProducts;

  DashboardStats({
    required this.totalOrders,
    required this.totalRevenue,
    required this.registeredCustomers,
    required this.activeDrivers,
    required this.averageDeliveryTime,
    required this.ordersByStatus,
    required this.topProducts,
  });
}

class TopProduct {
  final String name;
  final int quantity;
  final double revenue;

  TopProduct({
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}