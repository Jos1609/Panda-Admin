import 'package:flutter/foundation.dart';
import 'package:panda_admin/models/filter_state.dart';
import '../models/order_model.dart';
import '../utils/filter_utils.dart';

class FilterProvider with ChangeNotifier {
  // Cache de filtros para optimizar rendimiento
  final Map<String, List<DeliveryOrder>> _filteredOrdersCache = {};
  
  // Estado de filtros
  FilterState _filterState = FilterState();
  
  // Lista de pedidos
  List<DeliveryOrder> _allOrders = [];

  // Getters para el estado
  DateTime? get startDate => _filterState.startDate;
  DateTime? get endDate => _filterState.endDate;
  OrderStatus? get statusFilter => _filterState.status;
  String get searchQuery => _filterState.searchQuery;
  String? get deliveryPersonId => _filterState.deliveryPersonId;
  bool get showOnlyUnpaid => _filterState.showOnlyUnpaid;
  bool get showOnlyUrgent => _filterState.showOnlyUrgent;

  // Getter optimizado para pedidos filtrados
  List<DeliveryOrder> get filteredOrders {
    final cacheKey = _generateCacheKey();
    
    if (_filteredOrdersCache.containsKey(cacheKey)) {
      return _filteredOrdersCache[cacheKey]!;
    }

    final filtered = _applyFilters();
    _filteredOrdersCache[cacheKey] = filtered;
    
    return filtered;
  }

  // Getter optimizado para total
  double get filteredOrdersTotal {
    return filteredOrders.fold(
      0.0,
      (total, order) => total + order.payment.deliveryFee,
    );
  }

  // Setters optimizados
  void setAllOrders(List<DeliveryOrder> orders) {
    if (listEquals(_allOrders, orders)) return;
    
    _allOrders = orders;
    _clearCache();
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    if (start == _filterState.startDate && end == _filterState.endDate) return;
    
    _filterState = _filterState.copyWith(
      startDate: start,
      endDate: end,
    );
    _clearCache();
    notifyListeners();
  }

  void setStatusFilter(OrderStatus? status) {
    if (status == _filterState.status) return;
    
    _filterState = _filterState.copyWith(status: status);
    _clearCache();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (query == _filterState.searchQuery) return;
    
    _filterState = _filterState.copyWith(searchQuery: query);
    _clearCache();
    notifyListeners();
  }

  void setDeliveryPersonFilter(String? id) {
    if (id == _filterState.deliveryPersonId) return;
    
    _filterState = _filterState.copyWith(deliveryPersonId: id);
    _clearCache();
    notifyListeners();
  }

  void toggleUnpaidFilter() {
    _filterState = _filterState.copyWith(
      showOnlyUnpaid: !_filterState.showOnlyUnpaid,
    );
    _clearCache();
    notifyListeners();
  }

  void toggleUrgentFilter() {
    _filterState = _filterState.copyWith(
      showOnlyUrgent: !_filterState.showOnlyUrgent,
    );
    _clearCache();
    notifyListeners();
  }

  void clearFilters() {
    _filterState = FilterState();
    _clearCache();
    notifyListeners();
  }

  // Métodos privados
  String _generateCacheKey() {
    return '${_filterState.toString()}_${_allOrders.length}';
  }

  void _clearCache() {
    _filteredOrdersCache.clear();
  }

  List<DeliveryOrder> _applyFilters() {
    return _allOrders.where((order) {
      if (!FilterUtils.matchesDateRange(
        order.orderDate,
        _filterState.startDate,
        _filterState.endDate,
      )) {
        return false;
      }

      if (!FilterUtils.matchesStatus(
        order.status,
        _filterState.status,
      )) {
        return false;
      }

      if (!FilterUtils.matchesSearch(
        order: order,
        query: _filterState.searchQuery,
      )) {
        return false;
      }

      if (!FilterUtils.matchesDeliveryPerson(
        order.delivery.deliveryPersonId,
        _filterState.deliveryPersonId,
      )) {
        return false;
      }

      if (!FilterUtils.matchesPaymentStatus(
        order.payment.isPaid,
        _filterState.showOnlyUnpaid,
      )) {
        return false;
      }

      if (!FilterUtils.matchesUrgency(
        order: order,
        showOnlyUrgent: _filterState.showOnlyUrgent,
      )) {
        return false;
      }

      return true;
    }).toList();
  }
}