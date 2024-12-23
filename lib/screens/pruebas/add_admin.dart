import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

class AddAdminUserScreen extends StatefulWidget {
  const AddAdminUserScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddAdminUserScreenState createState() => _AddAdminUserScreenState();
}

class _AddAdminUserScreenState extends State<AddAdminUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = 'admin';

  Future<void> _addAdminUser() async {
    if (_formKey.currentState!.validate()) {
      final uid = const Uuid().v4(); // Generar un ID único para el usuario

      final adminUser = {
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'name': _nameController.text.trim(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(uid)
            .set(adminUser);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Usuario admin agregado con éxito!')),
        );

        // Limpiar los campos del formulario
        _emailController.clear();
        _nameController.clear();
        setState(() {
          _selectedRole = 'admin';
        });
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Usuario Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un correo electrónico';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'superadmin', child: Text('Superadmin')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, seleccione un rol';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addAdminUser,
                child: const Text('Agregar Usuario Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
