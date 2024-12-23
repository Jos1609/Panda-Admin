import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;
import '../models/order_model.dart';

class ExportService {
  Future<File> exportOrdersToPdf(List<DeliveryOrder> orders) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(),
          _buildOrdersTable(orders),
          _buildSummary(orders),
        ],
      ),
    );

    // Guardar el archivo PDF
    final output = await _getOutputFile();
    await output.writeAsBytes(await pdf.save());
    return output;
  }

  Future<String> exportOrdersToCsv(List<DeliveryOrder> orders) async {
    final buffer = StringBuffer();
    
    // Escribir encabezados
    buffer.writeln(
      'ID,Fecha,Cliente,Dirección,Estado,Total,Repartidor,Pagado'
    );

    // Escribir datos
    for (final order in orders) {
      buffer.writeln(
        '${order.id},'
        '${order.orderDate},'
        '${_escapeCsvField(order.customerName)},'
        '${_escapeCsvField(order.customerAddress)},'
        '${order.status},'
        '${order.total},'
        '${order.deliveryPersonId ?? ""},'
        '${order.isPaid}'
      );
    }

    return buffer.toString();
  }

  pw.Widget _buildHeader() {
    // Implementar encabezado del PDF
    return pw.Header(
      level: 0,
      child: pw.Text('Reporte de Pedidos'),
    );
  }

  pw.Widget _buildOrdersTable(List<DeliveryOrder> orders) {
    // Implementar tabla de pedidos
    return pw.Table();
  }

  pw.Widget _buildSummary(List<DeliveryOrder> orders) {
    // Implementar resumen de pedidos
    return pw.Container();
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  Future<File> _getOutputFile() async {
    // Implementar lógica para obtener archivo de salida
    return File('orders_report.pdf');
  }
}