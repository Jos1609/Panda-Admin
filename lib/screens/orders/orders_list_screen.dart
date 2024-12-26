import 'package:flutter/material.dart';
import 'package:panda_admin/screens/orders/create_order_screen.dart';
import 'package:panda_admin/utils/navigation.dart';
import 'package:panda_admin/utils/screen_enum.dart';
import 'package:panda_admin/widgets/assign_delivery_dialog.dart';
import 'package:panda_admin/widgets/change_status_dialog.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/filter_provider.dart';
import '../../widgets/order_filter_bar.dart';
import '../../widgets/custom_status_badge.dart';
import '../../widgets/navigation_bar.dart';

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateOrderScreen(),
                ),
              );
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
      bottomNavigationBar: const NavigationBar1(
        currentScreen: Screen.orders,
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final DeliveryOrder order;

  const _OrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // Envolvemos con InkWell para tener el onTap
      onTap: () => AppNavigation.goToOrderDetail(context, order.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                      fontSize: 10,
                    ),
                  ),
                  Row(
                    children: [
                      CustomStatusBadge(status: order.status),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'details':
                              AppNavigation.goToOrderDetail(context, order.id);
                              break;
                            case 'assign':
                              _showAssignDeliveryDialog(context, order);
                              break;
                            case 'status':
                              _showChangeStatusDialog(context, order);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'details',
                            child: Row(
                              children: [
                                Icon(Icons.visibility_outlined),
                                SizedBox(width: 8),
                                Text('Ver detalles'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'assign',
                            child: Row(
                              children: [
                                Icon(Icons.person_add_outlined),
                                SizedBox(width: 8),
                                Text('Asignar repartidor'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'status',
                            child: Row(
                              children: [
                                Icon(Icons.update_outlined),
                                SizedBox(width: 8),
                                Text('Cambiar estado'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                    'Total: S/${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (!order.isPaid)
                    const Icon(
                      Icons.money_off,
                      color: Colors.red,
                      size: 20,
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

  void _showAssignDeliveryDialog(BuildContext context, DeliveryOrder order) {
    showDialog(
      context: context,
      builder: (context) => AssignDeliveryDialog(
        currentDeliveryPersonId: order.deliveryPersonId,
        onDeliveryPersonAssigned: (String deliveryPersonId) async {
          try {
            final orderProvider = context.read<OrderProvider>();
            await orderProvider.assignDeliveryPerson(
              order.id,
              deliveryPersonId,
            );
            if (context.mounted) {
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

  void _showChangeStatusDialog(BuildContext context, DeliveryOrder order) {
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
              'Admin', // TODO: Obtener el usuario actual
            );
            if (context.mounted) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
