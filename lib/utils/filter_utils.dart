import 'package:panda_admin/models/order_model.dart';

class FilterUtils {
  static bool matchesDateRange(
    DateTime orderDate,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate != null && orderDate.isBefore(startDate)) return false;
    if (endDate != null && orderDate.isAfter(endDate)) return false;
    return true;
  }

  static bool matchesStatus(OrderStatus orderStatus, OrderStatus? filterStatus) {
    if (filterStatus == null) return true;
    return orderStatus == filterStatus;
  }

  static bool matchesSearch({
    required DeliveryOrder order,
    required String query,
  }) {
    if (query.isEmpty) return true;
    
    final searchLower = query.toLowerCase();
    return order.customer.name.toLowerCase().contains(searchLower) ||
           order.customer.address.toLowerCase().contains(searchLower) ||
           order.id.toLowerCase().contains(searchLower);
  }

  static bool matchesDeliveryPerson(
    String? orderDeliveryId,
    String? filterDeliveryId,
  ) {
    if (filterDeliveryId == null) return true;
    return orderDeliveryId == filterDeliveryId;
  }

  static bool matchesPaymentStatus(bool isPaid, bool showOnlyUnpaid) {
    if (!showOnlyUnpaid) return true;
    return !isPaid;
  }

  static bool matchesUrgency({
    required DeliveryOrder order,
    required bool showOnlyUrgent,
  }) {
    if (!showOnlyUrgent) return true;
    
    return order.status == OrderStatus.pending &&
           DateTime.now().difference(order.orderDate).inMinutes >= 10;
  }
}