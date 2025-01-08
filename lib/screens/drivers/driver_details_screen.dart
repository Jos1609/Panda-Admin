// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panda_admin/screens/drivers/delivery_history_section.dart';
import '../../models/driver.dart';
import '../../services/driver_service.dart';
import '../../services/auth_service.dart';
import '../../utils/status_helpers.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/add_driver_form.dart';

class DriverDetailsScreen extends StatefulWidget {
  final Driver driver;

  const DriverDetailsScreen({
    super.key,
    required this.driver,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DriverDetailsScreenState createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  final DriverService _driverService = DriverService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshDriverData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildStatusSection(),
                    const SizedBox(height: 24),
                    _buildPerformanceMetrics(),
                    const SizedBox(height: 24),
                    _buildDeliveryHistory(),
                  ],
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Detalles del Repartidor'),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar información'),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            const PopupMenuItem(
              value: 'change_status',
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('Cambiar estado'),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            const PopupMenuItem(
              value: 'reset_password',
              child: ListTile(
                leading: Icon(Icons.lock_reset),
                title: Text('Restablecer contraseña'),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar repartidor',
                    style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return CustomCard(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: widget.driver.photoUrl != null
                    ? NetworkImage(widget.driver.photoUrl!)
                    : null,
                child: widget.driver.photoUrl == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: getStatusColor(widget.driver.status),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getStatusIcon(widget.driver.status),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.driver.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                widget.driver.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Teléfono'),
          subtitle: Text(widget.driver.phoneNumber),
          trailing: IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: () => _copyToClipboard(widget.driver.phoneNumber),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Correo electrónico'),
          subtitle: Text(widget.driver.email),
          trailing: IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: () => _copyToClipboard(widget.driver.email),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Dirección'),
          subtitle: Text(widget.driver.address),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado Actual',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StatusBadge(status: widget.driver.status),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Cambiar Estado'),
                onPressed: () => _showChangeStatusDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas de Desempeño',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildMetricTile(
            icon: Icons.local_shipping,
            title: 'Entregas Totales',
            value: widget.driver.totalDeliveries.toString(),
          ),
          _buildMetricTile(
            icon: Icons.timer,
            title: 'Tiempo Promedio de Entrega',
            value:
                '${widget.driver.averageDeliveryTime.toStringAsFixed(1)} min',
          ),
          _buildMetricTile(
            icon: Icons.schedule,
            title: 'Entregas a Tiempo',
            value:
                '${widget.driver.onTimeDeliveryPercentage.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDeliveryHistory() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historial de Entregas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  // Navegar directamente a la vista detallada del historial
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DeliveryHistorySection(driverId: widget.driver.id),
                    ),
                  );
                },
                child: const Text('Ver todo'),
              ),
            ],
          ),
          // Aquí puedes agregar un StreamBuilder para mostrar
          // las últimas entregas del repartidor
        ],
      ),
    );
  }

  Future<Driver?> _refreshDriverData() async {
    setState(() => _isLoading = true);
    try {
      final updatedDriver =
          await _driverService.getDriverById(widget.driver.id);
      return updatedDriver;
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al obtener los datos del repartidor')),
      );
      return widget.driver;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleMenuAction(BuildContext context, String value) async {
    switch (value) {
      case 'edit':
        await _showEditDriverDialog();
        break;
      case 'change_status':
        await _showChangeStatusDialog();
        break;
      case 'reset_password':
        await _showResetPasswordConfirmation();
        break;
      case 'delete':
        await _showDeleteConfirmation();
        break;
    }
  }

  Future<void> _showEditDriverDialog() async {
    final updatedDriver = await showDialog<Driver>(
      context: context,
      builder: (context) => AddDriverForm(
        onSubmit: (driver) => Navigator.pop(context, driver),
        initialDriver: widget.driver,
      ),
    );

    if (updatedDriver != null) {
      setState(() => _isLoading = true);
      try {
        await _driverService.updateDriver(
            updatedDriver.id, updatedDriver.toMap());
        await _refreshDriverData();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información actualizada con éxito')),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar la información')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showChangeStatusDialog() async {
    final newStatus = await showDialog<DriverStatus>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DriverStatus.values.map((status) {
            return ListTile(
              leading: Icon(getStatusIcon(status)),
              title: Text(getStatusText(status)),
              onTap: () => Navigator.pop(context, status),
            );
          }).toList(),
        ),
      ),
    );

    if (newStatus != null && newStatus != widget.driver.status) {
      setState(() => _isLoading = true);
      try {
        await _driverService.updateDriver(
          widget.driver.id,
          {'status': newStatus.index},
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado con éxito')),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el estado')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showResetPasswordConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer Contraseña'),
        content: Text(
            '¿Está seguro de que desea enviar un enlace para restablecer la contraseña a ${widget.driver.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _authService.sendEmailVerification(widget.driver.email as User);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado el enlace de restablecimiento'),
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar el enlace de restablecimiento'),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Repartidor'),
        content: Text(
          '¿Está seguro de que desea eliminar a ${widget.driver.name}? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _driverService.deleteDriver(widget.driver.id);
        await _authService.deleteUserByEmail(widget.driver.email);
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Volver a la lista de repartidores
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repartidor eliminado con éxito'),
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el repartidor'),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copiado al portapapeles')),
    );
  }
}
