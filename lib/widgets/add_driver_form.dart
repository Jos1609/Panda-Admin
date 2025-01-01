// lib/widgets/add_driver_form.dart

import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../utils/validators.dart';

class AddDriverForm extends StatefulWidget {
  final Function(Driver) onSubmit;
  final Driver? initialDriver;

  const AddDriverForm({
    super.key,
    required this.onSubmit,
    this.initialDriver,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddDriverFormState createState() => _AddDriverFormState();
}

class _AddDriverFormState extends State<AddDriverForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialDriver?.name ?? '');
    _phoneController = TextEditingController(text: widget.initialDriver?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.initialDriver?.email ?? '');
    _addressController = TextEditingController(text: widget.initialDriver?.address ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.initialDriver == null ? 'Agregar Repartidor' : 'Editar Repartidor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.required,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final driver = Driver(
        id: widget.initialDriver?.id ?? '',
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        status: widget.initialDriver?.status ?? DriverStatus.available,
        rating: widget.initialDriver?.rating ?? 0.0,
        totalDeliveries: widget.initialDriver?.totalDeliveries ?? 0,
        averageDeliveryTime: widget.initialDriver?.averageDeliveryTime ?? 0.0,
        onTimeDeliveryPercentage: widget.initialDriver?.onTimeDeliveryPercentage ?? 0.0,
      );
      widget.onSubmit(driver);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}