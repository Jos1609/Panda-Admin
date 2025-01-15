import 'dart:async';
import 'package:flutter/material.dart';
import 'package:panda_admin/models/customer_model.dart';
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
  late StoreData _selectedStore;
  final _notesController = TextEditingController();
  final List<OrderItem> _items = [];
  double _deliveryFee = 0.0;
  List<Customer> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  List<StoreData> _stores = [];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _notesController.dispose();
    _debounceTimer?.cancel();
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
    final tax = subtotal * 0; // 18% de impuesto

    final order = DeliveryOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customer: CustomerData(
        name: _customerNameController.text,
        phone: _customerPhoneController.text,
        address: _customerAddressController.text,
      ),
      store: StoreData(
        id: _selectedStore.id,
        name: _selectedStore.name,
        address: _selectedStore.address,
        location: Location(
          latitude: _selectedStore.location.latitude,
          longitude: _selectedStore.location.longitude,
        ),
        phone: _selectedStore.phone,
        instructions: _selectedStore.instructions,
      ),
      orderDate: DateTime.now(),
      status: OrderStatus.pending,
      items: _items,
      payment: PaymentData(
        subtotal: subtotal,
        tax: tax,
        deliveryFee: _deliveryFee,
        total: subtotal + tax + _deliveryFee,
        isPaid: false,
        paymentMethod: null,
        paymentReference: null,
      ),
      delivery: DeliveryData(
        deliveryPersonId: null,
        notes: _notesController.text,
        statusHistory: [
          StatusLog(
            status: OrderStatus.pending,
            timestamp: DateTime.now(),
            updatedBy: 'Admin',
          ),
        ],
      ),
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
            _buildStoreSection(),
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

  Widget _buildStoreSection() {
    if (_stores.isEmpty) {
      // Si no hay tiendas, muestra un botón para agregar una nueva tienda.
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
                'No hay tiendas disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddStoreDialog(
                    context), // Abre el diálogo para agregar tienda
                icon: const Icon(Icons.add),
                label: const Text('Agregar Tienda'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Dropdown con tiendas cargadas
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
              'Seleccionar Tienda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StoreData>(
              value: _selectedStore,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _stores.map((store) {
                return DropdownMenuItem(
                  value: store,
                  child: Text(store.name),
                );
              }).toList(),
              onChanged: (StoreData? value) {
                if (value != null) {
                  setState(() {
                    _selectedStore = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una tienda';
                }
                return null;
              },
            ),
          ],
        ),
      ),
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
            Stack(
              children: [
                Column(
                  children: [
                    CustomTextFieldOrder(
                      controller: _customerNameController,
                      label: 'Nombre',
                      icon: Icons.person,
                      validator: Validators.required,
                      onChanged: _onCustomerNameChanged,
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
                if (_showSuggestions)
                  Positioned(
                    top: 60, // Ajusta esta posición según necesites
                    left: 0,
                    right: 0,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final customer = _suggestions[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                customer.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${customer.phone}\n${customer.address}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              isThreeLine: true,
                              onTap: () => _selectCustomer(customer),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
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
            const SizedBox(height: 14),
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CustomTextFieldOrder(
              controller: _notesController,
              label: 'Notas',
              icon: Icons.note,
              maxLines: 2,
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
            // ignore: deprecated_member_use
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

  Future<void> _loadStores() async {
    try {
      final stores = await context.read<OrderProvider>().getStores();
      setState(() {
        _stores = stores;
        if (stores.isNotEmpty) {
          _selectedStore = stores.first;
        } else {
          // Manejo cuando no hay tiendas disponibles
          _selectedStore = StoreData(
            id: '',
            name: 'Sin tienda',
            address: 'No disponible',
            location: Location(latitude: 0.0, longitude: 0.0),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar las tiendas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddStoreDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final latitudeController = TextEditingController();
    final longitudeController = TextEditingController();
    final phoneController = TextEditingController();
    final instructionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Tienda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre de la Tienda'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitud'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitud'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Teléfono (Opcional)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: instructionsController,
                  decoration: const InputDecoration(
                      labelText: 'Instrucciones (Opcional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin guardar
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Crear un nuevo objeto StoreData
                final newStore = StoreData(
                  id: DateTime.now().toString(), // Generar un ID único
                  name: nameController.text,
                  address: addressController.text,
                  location: Location(
                    latitude: double.tryParse(latitudeController.text) ?? 0.0,
                    longitude:
                        double.tryParse(longitudeController.text) ?? 0.0,
                  ),
                  phone: phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                  instructions: instructionsController.text.isEmpty
                      ? null
                      : instructionsController.text,
                );

                setState(() {
                  _stores.add(newStore); // Agregar la nueva tienda a la lista
                  _selectedStore = newStore; // Seleccionar la nueva tienda
                });

                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

// Método para buscar clientes con debounce
  void _onCustomerNameChanged(String value) {
    // Cancelar el timer anterior si existe
    _debounceTimer?.cancel();

    if (value.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }

    // Crear un nuevo timer para hacer la búsqueda
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results =
            await context.read<OrderProvider>().searchCustomers(value);
        if (mounted) {
          setState(() {
            _suggestions = results.map((map) => Customer.fromMap(map)).toList();
            _showSuggestions = _suggestions.isNotEmpty;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al buscar clientes: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _customerNameController.text = customer.name;
      _customerPhoneController.text = customer.phone;
      _customerAddressController.text = customer.address;
      _showSuggestions = false;
      _suggestions.clear();
    });
  }
}
