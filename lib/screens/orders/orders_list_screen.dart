import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/filter_provider.dart';
import '../../widgets/order_filter_bar.dart';
import '../../widgets/custom_status_badge.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializar el provider de pedidos
    Future.microtask(
      // ignore: use_build_context_synchronously
      () => context.read<OrderProvider>().initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navegar a la pantalla de crear pedido
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              // TODO: Implementar exportación
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: OrderFilterBar(),
          ),
          Expanded(
            child: Consumer2<OrderProvider, FilterProvider>(
              builder: (context, orderProvider, filterProvider, child) {
                if (orderProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (orderProvider.error != null) {
                  return Center(
                    child: Text(
                      'Error: ${orderProvider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final filteredOrders = filterProvider.applyFilters(
                  orderProvider.orders,
                );

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron pedidos'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _OrderCard(order: order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final DeliveryOrder order;

  const _OrderCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalles del pedido
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  CustomStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.person,
                order.customerName,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_on,
                order.customerAddress,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time,
                _formatDate(order.orderDate),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      if (!order.isPaid)
                        const Icon(
                          Icons.money_off,
                          color: Colors.red,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'details',
                            child: Text('Ver detalles'),
                          ),
                          const PopupMenuItem(
                            value: 'assign',
                            child: Text('Asignar repartidor'),
                          ),
                          const PopupMenuItem(
                            value: 'status',
                            child: Text('Cambiar estado'),
                          ),
                        ],
                        onSelected: (value) {
                          // TODO: Implementar acciones
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}