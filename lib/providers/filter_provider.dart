import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class FilterProvider with ChangeNotifier {
  // Estado de filtros
  DateTime? _startDate;
  DateTime? _endDate;
  OrderStatus? _statusFilter;
  String _searchQuery = '';
  String? _deliveryPersonId;
  bool _showOnlyUnpaid = false;
  bool _showOnlyUrgent = false;

  // Lista de pedidos completa
  List<DeliveryOrder> _allOrders = [];

  // Getters
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  OrderStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  String? get deliveryPersonId => _deliveryPersonId;
  bool get showOnlyUnpaid => _showOnlyUnpaid;
  bool get showOnlyUrgent => _showOnlyUrgent;

  /// Getter para obtener pedidos filtrados
  List<DeliveryOrder> get filteredOrders => applyFilters(_allOrders);

  /// Getter para calcular el total de los pedidos filtrados
  double get filteredOrdersTotal {
    for (var order in filteredOrders) {
      if (kDebugMode) {
        print('Order ID: ${order.id}, Delivery Fee: ${order.deliveryFee}');
      }
    }
    return filteredOrders.fold(0.0, (total, order) => total + order.deliveryFee);
  }

  // Setters con notificación
  void setAllOrders(List<DeliveryOrder> orders) {
    if (kDebugMode) {
      print('Setting orders: ${orders.length}');
    }
    _allOrders = orders;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setStatusFilter(OrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDeliveryPersonFilter(String? id) {
    _deliveryPersonId = id;
    notifyListeners();
  }

  void toggleUnpaidFilter() {
    _showOnlyUnpaid = !_showOnlyUnpaid;
    notifyListeners();
  }

  void toggleUrgentFilter() {
    _showOnlyUrgent = !_showOnlyUrgent;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _statusFilter = null;
    _searchQuery = '';
    _deliveryPersonId = null;
    _showOnlyUnpaid = false;
    _showOnlyUrgent = false;
    notifyListeners();
  }

  // Aplicar filtros a una lista de pedidos
  List<DeliveryOrder> applyFilters(List<DeliveryOrder> orders) {
    return orders.where((order) {
      // Filtro por fecha
      if (_startDate != null && order.orderDate.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && order.orderDate.isAfter(_endDate!)) {
        return false;
      }

      // Filtro por estado
      if (_statusFilter != null && order.status != _statusFilter) {
        return false;
      }

      // Filtro por búsqueda
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        final matchesSearch =
            order.customerName.toLowerCase().contains(searchLower) ||
                order.customerAddress.toLowerCase().contains(searchLower) ||
                order.id.toLowerCase().contains(searchLower);
        if (!matchesSearch) return false;
      }

      // Filtro por repartidor
      if (_deliveryPersonId != null &&
          order.deliveryPersonId != _deliveryPersonId) {
        return false;
      }

      // Filtro por pagos pendientes
      if (_showOnlyUnpaid && order.isPaid) {
        return false;
      }

      // Filtro por pedidos urgentes (más de 10 minutos en estado pendiente)
      if (_showOnlyUrgent) {
        final isUrgent = order.status == OrderStatus.pending &&
            DateTime.now().difference(order.orderDate).inMinutes >= 10;
        if (!isUrgent) return false;
      }

      return true;
    }).toList();
  }
}
