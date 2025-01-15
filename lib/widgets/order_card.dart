import 'package:flutter/material.dart';
import 'package:panda_admin/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
Widget build(BuildContext context) {
  return Card(
    elevation: 4,  // Mayor elevación para un efecto de sombra más elegante
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),  // Esquinas más redondeadas
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order.id}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,  // Reducir el tamaño del título
                      ),
                ),
                Text(
                  _getStatusText(order.status),
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,  // Reducir tamaño del estado
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cliente: ${order.customer.name}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,  // Reducir tamaño
                    color: Colors.black87,  // Color oscuro para mejor contraste
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dirección: ${order.customer.address}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,  // Reducir tamaño
                    color: Colors.grey[600],  // Colorear en gris suave
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fecha: ${order.orderDate}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,  // Reducir tamaño
                        color: Colors.grey[700],  // Gris suave para detalles
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),  // Espacio adicional entre la fecha y el total
            Text(
              'Total: S/ ${order.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,  // Reducir tamaño
                    fontWeight: FontWeight.bold,
                    color: Colors.black,  // Color negro para destacar el total
                  ),
            ),
          ],
        ),
      ),
    ),
  );
}


  /// Mapea `OrderStatus` a un texto legible.
  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente de asignación';
      case OrderStatus.assigned:
        return 'Asignado a repartidor';
      case OrderStatus.inProgress:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
      }
  }

  /// Asigna colores según el estado del pedido.
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.assigned:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.cyan;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      }
  }
}
