import 'package:flutter/material.dart';
import 'package:panda_admin/models/order_model.dart';
import 'package:panda_admin/screens/orders/order_detail_screen.dart';
import '../../widgets/order_card.dart';
import '../../widgets/custom_card.dart';
import '../../services/order_service.dart';
import '../../utils/constants.dart';

class DeliveryHistorySection extends StatelessWidget {
  final String driverId;
  final OrderService _orderService = OrderService();

  DeliveryHistorySection({
    super.key,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Historial de Pedidos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize:25, // Tamaño más pequeño
              ),
        ),
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(
            context,
            '/driver-orders',
            arguments: driverId,
          ),
          icon: const Icon(Icons.history, size: 20), // Icono más pequeño
          label: const Text(
            'Ver todo',
            style: TextStyle(fontSize: 16), // Texto más pequeño
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    return StreamBuilder<List<DeliveryOrder>>(
      stream: _orderService.getDriverOrders(driverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return OrderCard(
              order: snapshot.data![index],
              onTap: () => _showOrderDetails(context, snapshot.data![index]),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 32, // Icono más pequeño
              color: AppTheme.errorColor,
            ),
            SizedBox(height: 12),
            Text(
              'Error al cargar los pedidos',
              style: TextStyle(
                fontSize: 14, // Texto más pequeño
                color: AppTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 48, // Icono más pequeño
              color: AppTheme.textLightColor,
            ),
            SizedBox(height: 12),
            Text(
              'Sin pedidos asignados',
              style: TextStyle(
                fontSize: 14, // Texto más pequeño
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los pedidos asignados aparecerán aquí',
              style: TextStyle(
                fontSize: 12, // Texto más pequeño
                color: AppTheme.textLightColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, DeliveryOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailScreen(orderId: order.id),
    );
  }
}
