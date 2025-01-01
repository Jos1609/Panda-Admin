// lib/screens/drivers_screen.dart

import 'package:flutter/material.dart';
import 'package:panda_admin/screens/drivers/driver_details_screen.dart';
import 'package:panda_admin/utils/screen_enum.dart';
import 'package:panda_admin/widgets/navigation_bar.dart';
import '../../models/driver.dart';
import '../../services/driver_service.dart';
import '../../widgets/driver_list_item.dart';
import '../../widgets/driver_filter.dart';
import '../../widgets/add_driver_form.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DriversScreenState createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final DriverService _driverService = DriverService();
  String _searchQuery = '';
  DriverStatus? _statusFilter;
  double? _ratingFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Repartidores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDriverDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          DriverFilter(
            onStatusChanged: (status) => setState(() => _statusFilter = status),
            onRatingChanged: (rating) => setState(() => _ratingFilter = rating),
          ),
          Expanded(
            child: StreamBuilder<List<Driver>>(
              stream: _driverService.getDriversStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar repartidores'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final drivers = _filterDrivers(snapshot.data!);

                return ListView.builder(
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    return DriverListItem(
                      driver: drivers[index],
                      onTap: () => _showDriverDetails(drivers[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavigationBar1(
        currentScreen: Screen.drivers,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar repartidor...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  List<Driver> _filterDrivers(List<Driver> drivers) {
    return drivers.where((driver) {
      final matchesSearch = driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.phoneNumber.contains(_searchQuery);
      final matchesStatus = _statusFilter == null || driver.status == _statusFilter;
      final matchesRating = _ratingFilter == null || driver.rating >= _ratingFilter!;
      
      return matchesSearch && matchesStatus && matchesRating;
    }).toList();
  }

  void _showAddDriverDialog() {
    showDialog(
      context: context,
      builder: (context) => AddDriverForm(
        onSubmit: (Driver driver) async {
          await _driverService.createDriver(driver, driver.name);
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDriverDetails(Driver driver) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DriverDetailsScreen(driver: driver),
    ),
  );
}

}