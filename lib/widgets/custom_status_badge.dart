import 'package:flutter/material.dart';
import '../models/order_model.dart';

class CustomStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const CustomStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor() {
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

  String _getStatusText() {
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