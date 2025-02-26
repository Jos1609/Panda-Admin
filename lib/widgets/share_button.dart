// lib/widgets/share_button.dart
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/whatsapp_service.dart';

class ShareButton extends StatelessWidget {
  final DeliveryOrder order;

  const ShareButton({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _shareOrderDetails(context, order),
    );
  }

  Future<void> _shareOrderDetails(
      BuildContext context, DeliveryOrder order) async {
    try {
      final message =
          'Gracias por confiar en Panda delivery. Aquí está el detalle de su pedido:\n'
          'Productos:\n'
          '${order.items.map((item) => '- ${item.quantity}x ${item.name} (S/ ${item.price.toStringAsFixed(2)}) '
              'subTotal: S/ ${(item.quantity * item.price).toStringAsFixed(2)}]').join('\n')}\n'
          'Subtotal: S/ ${order.payment.subtotal.toStringAsFixed(2)}\n'
          'Delivery: S/ ${order.payment.deliveryFee.toStringAsFixed(2)}\n'
          '*Total: S/ ${order.total.toStringAsFixed(2)}*\n\n'
          '¡Recuerda que somos Panda, el aliado perfecto para llegar por ti a donde tú quieras!';

      await WhatsAppService.shareOrderDetails(order.customer.phone, message);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detalle del pedido compartido en WhatsApp'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir el detalle del pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
