import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:panda_admin/models/payment_model.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/delivery_service.dart';
import '../utils/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Estado
  List<DeliveryOrder> _orders = [];
  bool _isLoading = false;
  String? _error;
  DeliveryOrder? _selectedOrder;

  // Filtros
  DateTime? _startDate;
  DateTime? _endDate;
  OrderStatus? _statusFilter;
  String? _searchQuery;
  String? _deliveryPersonId;

  // Getters
  List<DeliveryOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DeliveryOrder? get selectedOrder => _selectedOrder;

  // Estadísticas
  Map<OrderStatus, int> get ordersByStatus {
    return groupBy(_orders, (DeliveryOrder order) => order.status)
        .map((key, value) => MapEntry(key, value.length));
  }

  double get totalRevenue {
    return _orders.fold(0, (sum, order) => sum + order.total);
  }

  // Inicializar y escuchar cambios
  void initialize() {
    _setupOrdersListener();
  }

  void _setupOrdersListener() {
    _setLoading(true);

    _orderService
        .getOrders(
      startDate: _startDate,
      endDate: _endDate,
      statusFilter: _statusFilter,
      searchQuery: _searchQuery,
      deliveryPersonId: _deliveryPersonId,
    )
        .listen(
      (orders) {
        _orders = orders;
        _error = null;
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _setLoading(false);
        notifyListeners();
      },
    );
  }

  // Acciones de pedidos
  Future<void> createOrder(DeliveryOrder order) async {
    try {
      _setLoading(true);
      await _orderService.createOrder(order);
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Método para actualizar estado con validaciones
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
    String updatedBy,
  ) async {
    try {
      _setLoading(true);

      final order = _orders.firstWhere((o) => o.id == orderId);

      // Validaciones de cambio de estado
      if (order.status == OrderStatus.cancelled) {
        throw AppException(
          'No se puede cambiar el estado de un pedido cancelado',
        );
      }

      if (order.status == OrderStatus.delivered &&
          newStatus != OrderStatus.cancelled) {
        throw AppException(
          'No se puede cambiar el estado de un pedido entregado',
        );
      }

      // Si se está cancelando, liberamos al repartidor
      if (newStatus == OrderStatus.cancelled &&
          order.deliveryPersonId != null) {
        final deliveryService = DeliveryService();
        await deliveryService.removeOrderFromDeliveryPerson(
          order.deliveryPersonId!,
          orderId,
        );
      }

      await _orderService.updateOrderStatus(
        orderId,
        newStatus,
        updatedBy,
      );

      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Método para asignar repartidor
  Future<void> assignDeliveryPerson(
      String orderId, String deliveryPersonId) async {
    try {
      _setLoading(true);

      // Primero actualizamos el pedido
      await _orderService.assignDeliveryPerson(orderId, deliveryPersonId);

      // Luego actualizamos el repartidor
      final deliveryService = DeliveryService();
      await deliveryService.addOrderToDeliveryPerson(
        deliveryPersonId,
        orderId,
      );

      // Si había un repartidor anterior, lo actualizamos
      final order = _orders.firstWhere((o) => o.id == orderId);
      if (order.deliveryPersonId != null &&
          order.deliveryPersonId != deliveryPersonId) {
        await deliveryService.removeOrderFromDeliveryPerson(
          order.deliveryPersonId!,
          orderId,
        );
      }

      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    try {
      final QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('customerName', isGreaterThanOrEqualTo: query)
          .where('customerName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return ordersSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['customerName'] ?? '',
          'phone': data['customerPhone'] ?? '',
          'address': data['customerAddress'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error searching customers: $e');
      return [];
    }
  }

  // Manejo de filtros
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _setupOrdersListener();
  }

  void setStatusFilter(OrderStatus? status) {
    _statusFilter = status;
    _setupOrdersListener();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _setupOrdersListener();
  }

  void setDeliveryPersonFilter(String? deliveryPersonId) {
    _deliveryPersonId = deliveryPersonId;
    _setupOrdersListener();
  }

  // Selección de pedido
  void selectOrder(String orderId) {
    _selectedOrder = _orders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => _selectedOrder!,
    );
    notifyListeners();
  }

  // Utilidades
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> updatePaymentStatus(String orderId, bool isPaid) async {
    try {
      _setLoading(true);
      await _orderService.updatePaymentStatus(orderId, isPaid);
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Agregar este método a la clase OrderProvider
  Future<void> updatePaymentInfo(
    String orderId,
    PaymentMethod method,
    String? reference,
    bool isPaid,
  ) async {
    try {
      _setLoading(true);
      await _orderService.updatePaymentInfo(
        orderId,
        method,
        reference,
        isPaid,
      );
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
}
