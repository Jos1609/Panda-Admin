import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaymentMethodDialog extends StatefulWidget {
  final PaymentMethod? currentMethod;
  final String? currentReference;
  final Function(PaymentMethod, String?) onPaymentUpdated;

  const PaymentMethodDialog({
    super.key,
    this.currentMethod,
    this.currentReference,
    required this.onPaymentUpdated,
  });

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  late PaymentMethod? selectedMethod;
  final TextEditingController referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedMethod = widget.currentMethod;
    referenceController.text = widget.currentReference ?? '';
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Método de Pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PaymentMethod.values.map((method) {
                return ChoiceChip(
                  selected: selectedMethod == method,
                  onSelected: (selected) {
                    setState(() {
                      selectedMethod = selected ? method : null;
                    });
                  },
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(method.icon, size: 18),
                      const SizedBox(width: 4),
                      Text(method.name),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (selectedMethod != PaymentMethod.cash) ...[
              const SizedBox(height: 16),
              TextField(
                controller: referenceController,
                decoration: const InputDecoration(
                  labelText: 'Referencia de pago',
                  hintText: 'Ej: Últimos 4 dígitos, código de operación',
                ),
              ),
            ],
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
                  onPressed: selectedMethod == null
                      ? null
                      : () {
                          widget.onPaymentUpdated(
                            selectedMethod!,
                            selectedMethod == PaymentMethod.cash
                                ? null
                                : referenceController.text,
                          );
                          Navigator.pop(context);
                        },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}