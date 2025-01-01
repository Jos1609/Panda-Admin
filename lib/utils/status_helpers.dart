// lib/utils/status_helpers.dart

import 'package:flutter/material.dart';
import '../models/driver.dart';

/// Obtiene el texto descriptivo para cada estado del repartidor
String getStatusText(DriverStatus status) {
  switch (status) {
    case DriverStatus.available:
      return 'Disponible';
    case DriverStatus.busy:
      return 'En entrega';
    case DriverStatus.outOfService:
      return 'Fuera de servicio';
    }
}

/// Obtiene el color asociado a cada estado del repartidor
Color getStatusColor(DriverStatus status) {
  switch (status) {
    case DriverStatus.available:
      return Colors.green;
    case DriverStatus.busy:
      return Colors.orange;
    case DriverStatus.outOfService:
      return Colors.grey;
    }
}

/// Obtiene el ícono asociado a cada estado del repartidor
IconData getStatusIcon(DriverStatus status) {
  switch (status) {
    case DriverStatus.available:
      return Icons.check_circle;
    case DriverStatus.busy:
      return Icons.delivery_dining;
    case DriverStatus.outOfService:
      return Icons.do_not_disturb;
    }
}

/// Widget para mostrar un indicador visual del estado
class StatusIndicator extends StatelessWidget {
  final DriverStatus status;
  final double size;

  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: getStatusColor(status),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: getStatusColor(status).withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar una etiqueta con el estado
class StatusBadge extends StatelessWidget {
  final DriverStatus status;
  final double height;
  final bool showIcon;

  const StatusBadge({
    super.key,
    required this.status,
    this.height = 32.0,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          // ignore: deprecated_member_use
          color: getStatusColor(status).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              getStatusIcon(status),
              color: getStatusColor(status),
              size: height * 0.6,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            getStatusText(status),
            style: TextStyle(
              color: getStatusColor(status),
              fontWeight: FontWeight.w600,
              fontSize: height * 0.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// Obtiene una lista de todos los estados posibles con sus detalles
List<Map<String, dynamic>> getAllStatuses() {
  return DriverStatus.values.map((status) {
    return {
      'status': status,
      'text': getStatusText(status),
      'color': getStatusColor(status),
      'icon': getStatusIcon(status),
    };
  }).toList();
}

/// Obtiene el próximo estado lógico basado en el estado actual
DriverStatus getNextStatus(DriverStatus currentStatus) {
  switch (currentStatus) {
    case DriverStatus.available:
      return DriverStatus.busy;
    case DriverStatus.busy:
      return DriverStatus.available;
    case DriverStatus.outOfService:
      return DriverStatus.available;
    }
}

/// Valida si un cambio de estado es permitido
bool isStatusChangeAllowed(DriverStatus currentStatus, DriverStatus newStatus) {
  // Prevenir cambios ilógicos, por ejemplo:
  // - No permitir cambiar directamente de "Fuera de servicio" a "En entrega"
  if (currentStatus == DriverStatus.outOfService && 
      newStatus == DriverStatus.busy) {
    return false;
  }
  
  return true;
}

/// Extension para agregar funcionalidades adicionales al enum DriverStatus
extension DriverStatusExtension on DriverStatus {
  String get text => getStatusText(this);
  Color get color => getStatusColor(this);
  IconData get icon => getStatusIcon(this);
  
  bool get isAvailable => this == DriverStatus.available;
  bool get isBusy => this == DriverStatus.busy;
  bool get isOutOfService => this == DriverStatus.outOfService;
  
  /// Verifica si el estado actual puede cambiar al estado proporcionado
  bool canChangeTo(DriverStatus newStatus) {
    return isStatusChangeAllowed(this, newStatus);
  }
  
  /// Obtiene el siguiente estado permitido
  DriverStatus get nextStatus => getNextStatus(this);
}