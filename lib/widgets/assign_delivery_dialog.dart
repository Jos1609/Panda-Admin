import 'package:flutter/material.dart';
import '../models/delivery_person_model.dart';
import '../services/delivery_service.dart';

class AssignDeliveryDialog extends StatefulWidget {
  final String? currentDeliveryPersonId;
  final Function(String) onDeliveryPersonAssigned;

  const AssignDeliveryDialog({
    super.key,
    this.currentDeliveryPersonId,
    required this.onDeliveryPersonAssigned,
  });

  @override
  State<AssignDeliveryDialog> createState() => _AssignDeliveryDialogState();
}

class _AssignDeliveryDialogState extends State<AssignDeliveryDialog> {
  final DeliveryService _deliveryService = DeliveryService();
  String? _selectedDeliveryPersonId;
  bool _isLoading = true;
  String? _error;
  List<DeliveryPerson> _deliveryPeople = [];

  @override
  void initState() {
    super.initState();
    _selectedDeliveryPersonId = widget.currentDeliveryPersonId;
    _loadDeliveryPeople();
  }

  Future<void> _loadDeliveryPeople() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final deliveryPeople = await _deliveryService.getAvailableDeliveryPeople();
      
      setState(() {
        _deliveryPeople = deliveryPeople;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Asignar Repartidor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              )
            else if (_deliveryPeople.isEmpty)
              const Text('No hay repartidores disponibles')
            else
              ..._deliveryPeople.map((person) => _buildDeliveryPersonOption(
                person,
              )),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedDeliveryPersonId == null
                      ? null
                      : () {
                          widget.onDeliveryPersonAssigned(
                            _selectedDeliveryPersonId!,
                          );
                          Navigator.pop(context);
                        },
                  child: const Text('Asignar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryPersonOption(DeliveryPerson person) {
    final isSelected = person.id == _selectedDeliveryPersonId;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDeliveryPersonId = person.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(person.name[0]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  Text(
                    person.phone,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
}