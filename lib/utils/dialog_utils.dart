import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/assign_delivery_dialog.dart';
import '../widgets/change_status_dialog.dart';

class DialogUtils {
  static void showAssignDeliveryDialog(BuildContext context, DeliveryOrder order) {
    showDialog(
      context: context,
      builder: (context) => AssignDeliveryDialog(
        currentDeliveryPersonId: order.delivery.deliveryPersonId,
        onDeliveryPersonAssigned: (String deliveryPersonId) async {
          try {
            final orderProvider = context.read<OrderProvider>();
            await orderProvider.assignDeliveryPerson(
              order.id,
              deliveryPersonId,
            );
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Repartidor asignado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al asignar repartidor: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  static void showChangeStatusDialog(BuildContext context, DeliveryOrder order) {
    showDialog(
      context: context,
      builder: (context) => ChangeStatusDialog(
        currentStatus: order.status,
        onStatusChanged: (OrderStatus newStatus) async {
          try {
            final orderProvider = context.read<OrderProvider>();
            await orderProvider.updateOrderStatus(
              order.id,
              newStatus,
              'Admin', //Obtener el usuario actual
            );
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estado actualizado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al actualizar estado: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}