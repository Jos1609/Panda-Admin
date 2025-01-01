// lib/widgets/driver_filter.dart

import 'package:flutter/material.dart';
import '../models/driver.dart';

class DriverFilter extends StatelessWidget {
  final Function(DriverStatus?) onStatusChanged;
  final Function(double?) onRatingChanged;

  const DriverFilter({
    super.key,
    required this.onStatusChanged,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<DriverStatus>(
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: DriverStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(getStatusText(status)),
                );
              }).toList(),
              onChanged: onStatusChanged,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<double>(
              decoration: const InputDecoration(
                labelText: 'Calificación mínima',
                border: OutlineInputBorder(),
              ),
              items: [0, 1, 2, 3, 4, 5].map((rating) {
                return DropdownMenuItem(
                  value: rating.toDouble(),
                  child: Text('$rating estrellas'),
                );
              }).toList(),
              onChanged: onRatingChanged,
            ),
          ),
        ],
      ),
    );
  }

  String getStatusText(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'Disponible';
      case DriverStatus.busy:
        return 'Ocupado';
      case DriverStatus.outOfService:
        return 'Fuera de servicio';
    }
  }
}