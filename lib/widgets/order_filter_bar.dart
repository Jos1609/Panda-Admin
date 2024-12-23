import 'package:flutter/material.dart';
import 'package:panda_admin/widgets/custom_status_badge.dart';
import 'package:provider/provider.dart';
import '../providers/filter_provider.dart';
import '../models/order_model.dart';

class OrderFilterBar extends StatelessWidget {
  const OrderFilterBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: filterProvider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Buscar pedidos...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _BuildDateRangePicker(filterProvider: filterProvider),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusFilter(OrderStatus.pending, filterProvider),
                    _buildStatusFilter(OrderStatus.assigned, filterProvider),
                    _buildStatusFilter(OrderStatus.inProgress, filterProvider),
                    _buildStatusFilter(OrderStatus.delivered, filterProvider),
                    _buildStatusFilter(OrderStatus.cancelled, filterProvider),
                    const SizedBox(width: 8),
                    _buildToggleFilter(
                      'Solo Impagos',
                      Icons.money_off,
                      filterProvider.showOnlyUnpaid,
                      filterProvider.toggleUnpaidFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildToggleFilter(
                      'Urgentes',
                      Icons.warning,
                      filterProvider.showOnlyUrgent,
                      filterProvider.toggleUrgentFilter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilter(OrderStatus status, FilterProvider filterProvider) {
    final isSelected = filterProvider.statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: CustomStatusBadge(status: status),
        onSelected: (bool selected) {
          filterProvider.setStatusFilter(selected ? status : null);
        },
        backgroundColor: Colors.transparent,
        selectedColor: Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildToggleFilter(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onToggle,
  ) {
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (_) => onToggle(),
      backgroundColor: Colors.transparent,
      selectedColor: Colors.grey.withOpacity(0.2),
    );
  }
}

class _BuildDateRangePicker extends StatelessWidget {
  final FilterProvider filterProvider;

  const _BuildDateRangePicker({
    Key? key,
    required this.filterProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final DateTimeRange? dateRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          currentDate: DateTime.now(),
        );

        if (dateRange != null) {
          filterProvider.setDateRange(dateRange.start, dateRange.end);
        }
      },
      icon: const Icon(Icons.calendar_today),
      label: const Text('Rango de fechas'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}