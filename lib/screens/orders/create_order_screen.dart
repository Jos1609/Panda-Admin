import 'package:flutter/material.dart';
import 'package:panda_admin/models/order_item_model.dart';
import 'package:panda_admin/models/status_log_model.dart';
import 'package:panda_admin/widgets/custom_text_field_order.dart';
import 'package:panda_admin/widgets/add_item_bottom_sheet.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/validators.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _notesController = TextEditingController();
  final List<OrderItem> _items = [];
  double _deliveryFee = 0.0;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemBottomSheet(
        onItemAdded: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final subtotal = _items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0 ; // 18% de impuesto

    final order = DeliveryOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _customerNameController.text,
      customerPhone: _customerPhoneController.text,
      customerAddress: _customerAddressController.text,
      orderDate: DateTime.now(),
      status: OrderStatus.pending,
      items: _items,
      subtotal: subtotal,
      tax: tax,
      deliveryFee: _deliveryFee,
      total: subtotal + tax + _deliveryFee,
      notes: _notesController.text,
      statusHistory: [
        StatusLog(
          status: OrderStatus.pending,
          timestamp: DateTime.now(),
          updatedBy: 'Admin', // TODO: Obtener usuario actual
        ),
      ],
    );

    try {
      await context.read<OrderProvider>().createOrder(order);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Pedido'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCustomerSection(),
            const SizedBox(height: 24),
            _buildItemsSection(),
            const SizedBox(height: 24),
            _buildDeliverySection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildTotalSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            CustomTextFieldOrder(
              controller: _customerNameController,
              label: 'Nombre',
              icon: Icons.person,
              validator: Validators.required,
            ),
            const SizedBox(height: 12),
            CustomTextFieldOrder(
              controller: _customerPhoneController,
              label: 'Teléfono',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
            ),
            const SizedBox(height: 12),
            CustomTextFieldOrder(
              controller: _customerAddressController,
              label: 'Dirección',
              icon: Icons.location_on,
              maxLines: 2,
              validator: Validators.required,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
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
                const Text(
                  'Productos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                child: Text(
                  'No hay productos agregados',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.quantity}x S/ ${item.price.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _items.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Costo de Envío',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _deliveryFee.toString(),
              decoration: const InputDecoration(
                labelText: 'Costo de envío',
                prefixIcon: Icon(Icons.delivery_dining),
                prefixText: 'S/ ',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.required,
              onChanged: (value) {
                setState(() {
                  _deliveryFee = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notas Adicionales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextFieldOrder(
              controller: _notesController,
              label: 'Notas',
              icon: Icons.note,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    final subtotal = _items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0;
    final total = subtotal + tax + _deliveryFee;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', subtotal),
            const SizedBox(height: 8),
            _buildSummaryRow('Delivery', _deliveryFee),
            const Divider(height: 24),
            _buildSummaryRow('Total', total, isTotal: true),
          ],
        ),
      ),
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
          'S/ ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _createOrder,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Crear Pedido'),
      ),
    );
  }
}