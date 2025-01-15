import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:fl_chart/fl_chart.dart';
import 'package:panda_admin/utils/screen_enum.dart';
import 'package:panda_admin/widgets/navigation_bar.dart';
import '../widgets/stat_card.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_stats.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = true;
  DashboardStats? _stats;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _mounted = true;
  }

  Future<void> _loadDashboardData() async {
    try {
    if (_mounted) {
      setState(() => _isLoading = true);
    }
    final stats = await _dashboardService.getDashboardStats(
      startDate: _startDate,
      endDate: _endDate,
    );
    if (_mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (_mounted) {
      setState(() => _isLoading = false);
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar datos: $e')),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              // Implementar exportación de datos
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
    bottomNavigationBar: const NavigationBar1(
        currentScreen: Screen.dashboard,
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (_stats == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateFilter(),
          const SizedBox(height: 16),
          _buildStatCards(),
          const SizedBox(height: 24),
          _buildCharts(),
          const SizedBox(height: 24),
          _buildTopProducts(),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_formatDate(_startDate)),
                onPressed: () => _selectDate(true),
              ),
            ),
            const Text(' - '),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_formatDate(_endDate)),
                onPressed: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        StatCard(
          title: 'Pedidos Totales',
          value: _stats!.totalOrders.toString(),
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Ingresos Totales',
          value: 'S/ ${_stats!.totalRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        StatCard(
          title: 'Clientes Registrados',
          value: _stats!.registeredCustomers.toString(),
          icon: Icons.people,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Repartidores Activos',
          value: _stats!.activeDrivers.toString(),
          icon: Icons.delivery_dining,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildCharts() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de Pedidos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final Map<String, Color> statusColors = {
      'pendiente': Colors.orange,
      'en_camino': Colors.blue,
      'entregado': Colors.green,
      'cancelado': Colors.red,
    };

    return _stats!.ordersByStatus.entries.map((entry) {
      return PieChartSectionData(
        color: statusColors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildTopProducts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Más Vendidos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Producto')),
                DataColumn(label: Text('Cantidad')),
                DataColumn(label: Text('Ingresos')),
              ],
              rows: _stats!.topProducts
                  .map(
                    (product) => DataRow(
                      cells: [
                        DataCell(Text(product.name)),
                        DataCell(Text(product.quantity.toString())),
                        DataCell(
                          Text('S/ ${product.revenue.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _loadDashboardData();
    }
  }
}