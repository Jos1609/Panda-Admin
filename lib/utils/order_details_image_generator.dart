// lib/utils/order_details_image_generator.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../models/order_model.dart';

class OrderDetailsImageGenerator {
  static final _screenshotController = ScreenshotController();

  static Future<String> generateImage(DeliveryOrder order) async {
    // Capturar screenshot del detalle del pedido
    final image = await _screenshotController.captureFromWidget(
      _buildOrderDetailsImage(order),
    );

    // Guardar imagen en el dispositivo
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/order_details_${order.id}.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(image);

    return imagePath;
  }

  static Widget _buildOrderDetailsImage(DeliveryOrder order) {
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalle del pedido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Detalles del pedido (productos, subtotal, delivery, total)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                final subtotal = item.price * item.quantity;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Text(
                        'S/ ${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'S/ ${order.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'S/ ${order.deliveryFee.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'S/ ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}