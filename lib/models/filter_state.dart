import 'package:panda_admin/models/order_model.dart';

class FilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final OrderStatus? status;
  final String searchQuery;
  final String? deliveryPersonId;
  final bool showOnlyUnpaid;
  final bool showOnlyUrgent;

  FilterState({
    this.startDate,
    this.endDate,
    this.status,
    this.searchQuery = '',
    this.deliveryPersonId,
    this.showOnlyUnpaid = false,
    this.showOnlyUrgent = false,
  });

  FilterState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    OrderStatus? status,
    String? searchQuery,
    String? deliveryPersonId,
    bool? showOnlyUnpaid,
    bool? showOnlyUrgent,
  }) {
    return FilterState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      showOnlyUnpaid: showOnlyUnpaid ?? this.showOnlyUnpaid,
      showOnlyUrgent: showOnlyUrgent ?? this.showOnlyUrgent,
    );
  }

  @override
  String toString() {
    return '$startDate-$endDate-$status-$searchQuery-$deliveryPersonId-$showOnlyUnpaid-$showOnlyUrgent';
  }
}