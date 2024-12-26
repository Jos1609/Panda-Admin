import 'package:flutter/material.dart';
import 'package:panda_admin/utils/dialog_utils.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #$orderId'),
        actions: [
          Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              final order = orderProvider.orders.firstWhere(
                (order) => order.id == orderId,
              );

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: () =>
                        DialogUtils.showAssignDeliveryDialog(context, order),
                  ),
                  IconButton(
                    icon: const Icon(Icons.update_outlined),
                    onPressed: () =>
                        DialogUtils.showChangeStatusDialog(context, order),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final order = orderProvider.orders.firstWhere(
            (order) => order.id == orderId,
          );

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildOrderHeader(order),
              ),
              SliverToBoxAdapter(
                child: _buildCustomerInfo(order),
              ),
              SliverToBoxAdapter(
                child: _buildOrderItems(order),
              ),
              SliverToBoxAdapter(
                child: _buildOrderSummary(order),
              ),
              if (order.deliveryPersonId != null)
                SliverToBoxAdapter(
                  child: _buildDeliveryInfo(order),
                ),
              SliverToBoxAdapter(
                child: _buildStatusHistory(order),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildOrderHeader(DeliveryOrder order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${order.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(order.orderDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              CustomStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 16),
          if (order.notes != null && order.notes!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.notes!,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(DeliveryOrder order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Cliente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.person,
            'Nombre',
            order.customerName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.phone,
            'Teléfono',
            order.customerPhone,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on,
            'Dirección',
            order.customerAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(DeliveryOrder order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'Producto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Cantidad',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Precio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'S/ ${item.price.toStringAsFixed(2)}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(DeliveryOrder order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', order.subtotal),
          const SizedBox(height: 8),
          _buildSummaryRow('Delivery', order.deliveryFee),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total',
            order.total,
            isTotal: true,
          ),
          const SizedBox(height: 16),
          if (!order.isPaid)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Pendiente de Pago',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(DeliveryOrder order) {
    // TODO: Implementar información del repartidor
    return Container();
  }

  Widget _buildStatusHistory(DeliveryOrder order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de Estados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.statusHistory.length,
            itemBuilder: (context, index) {
              final statusLog = order.statusHistory[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.check_circle,
                  color: _getStatusColor(statusLog.status),
                ),
                title: Text(
                  _getStatusText(statusLog.status),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Por: ${statusLog.updatedBy}\n${_formatDateTime(statusLog.timestamp)}',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final order = orderProvider.orders.firstWhere(
            (order) => order.id == orderId,
          );

          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      DialogUtils.showChangeStatusDialog(context, order),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cambiar Estado'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      DialogUtils.showAssignDeliveryDialog(context, order),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Asignar Repartidor'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          'S/ ${amount.toStringAsFixed(2)}', // Formatea el monto con dos decimales
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.assigned:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.assigned:
        return 'Asignado';
      case OrderStatus.inProgress:
        return 'En Camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}
