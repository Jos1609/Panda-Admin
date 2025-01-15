import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panda_admin/models/order_model.dart';
import '../models/payment_model.dart';
import '../services/order_service.dart';
import '../services/delivery_service.dart';
import '../utils/app_exception.dart';

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
    return groupBy(_orders, (order) => order.status)
        .map((key, value) => MapEntry(key, value.length));
  }

  double get totalRevenue {
    // ignore: avoid_types_as_parameter_names
    return _orders.fold(0, (sum, order) => sum + order.payment.total);
  }

  // Inicialización y escucha
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

  // Operaciones CRUD
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

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
    String updatedBy,
  ) async {
    try {
      _setLoading(true);
      final order = _orders.firstWhere((o) => o.id == orderId);

      if (!_canUpdateStatus(order.status, newStatus)) {
        throw AppException('Cambio de estado no permitido');
      }

      if (newStatus == OrderStatus.cancelled &&
          order.delivery.deliveryPersonId != null) {
        await _handleDeliveryPersonRemoval(
            order.delivery.deliveryPersonId!, orderId);
      }

      await _orderService.updateOrderStatus(orderId, newStatus, updatedBy);
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> assignDeliveryPerson(
      String orderId, String deliveryPersonId) async {
    try {
      _setLoading(true);
      final order = _findOrder(orderId);

      await _updateDeliveryAssignment(order, deliveryPersonId);
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> updatePaymentInfo(
    String orderId,
    PaymentMethod method,
    String? reference,
    bool isPaid,
  ) async {
    try {
      _setLoading(true);
      await _orderService.updatePaymentInfo(orderId, method, reference, isPaid);
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Búsqueda de clientes
  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('customer.name', isGreaterThanOrEqualTo: query)
          .where('customer.name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['customer']['name'] ?? '',
          'phone': data['customer']['phone'] ?? '',
          'address': data['customer']['address'] ?? '',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) print('Error searching customers: $e');
      return [];
    }
  }

  // Filtros
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

  void setDeliveryPersonFilter(String? id) {
    _deliveryPersonId = id;
    _setupOrdersListener();
  }

  // Utilidades privadas
  bool _canUpdateStatus(OrderStatus current, OrderStatus next) {
    if (current == OrderStatus.cancelled) return false;
    if (current == OrderStatus.delivered && next != OrderStatus.cancelled) {
      return false;
    }
    return true;
  }

  DeliveryOrder _findOrder(String orderId) {
    return _orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => throw AppException('Pedido no encontrado'),
    );
  }

  Future<void> _handleDeliveryPersonRemoval(
      String deliveryPersonId, String orderId) async {
    final deliveryService = DeliveryService();
    await deliveryService.removeOrderFromDeliveryPerson(
        deliveryPersonId, orderId);
  }

  Future<void> _updateDeliveryAssignment(
      DeliveryOrder order, String newDeliveryId) async {
    final deliveryService = DeliveryService();

    await _orderService.assignDeliveryPerson(order.id, newDeliveryId);
    await deliveryService.addOrderToDeliveryPerson(newDeliveryId, order.id);

    if (order.delivery.deliveryPersonId != null &&
        order.delivery.deliveryPersonId != newDeliveryId) {
      await _handleDeliveryPersonRemoval(
          order.delivery.deliveryPersonId!, order.id);
    }
  }

  Future<List<StoreData>> getStores() async {
    try {
      // Accede a la colección "stores" en Firestore
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('stores').get();

      // Convierte los documentos de Firestore en una lista de objetos StoreData
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return StoreData.fromMap({
          ...data,
          'id': doc.id, // Incluye el ID del documento
        });
      }).toList();
    } catch (e) {
      // Manejo de errores
      if (kDebugMode) {
        print('Error al obtener las tiendas: $e');
      }
      return [];
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
