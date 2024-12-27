import 'package:flutter/material.dart';

enum PaymentMethod {
  cash,     // Efectivo
  yape,     // Yape
  plin,     // Plin
  card,     // Tarjeta
  transfer  // Transferencia
}

extension PaymentMethodExtension on PaymentMethod {
  String get name {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.yape:
        return 'Yape';
      case PaymentMethod.plin:
        return 'Plin';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.transfer:
        return 'Transferencia';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.yape:
        return Icons.qr_code;
      case PaymentMethod.plin:
        return Icons.qr_code;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.transfer:
        return Icons.account_balance;
    }
  }
}