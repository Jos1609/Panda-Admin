// lib/widgets/driver_list_item.dart

import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../utils/status_helpers.dart';

class DriverListItem extends StatelessWidget {
  final Driver driver;
  final VoidCallback onTap;

  const DriverListItem({
    super.key,
    required this.driver,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: driver.photoUrl != null
              ? NetworkImage(driver.photoUrl!)
              : null,
          child: driver.photoUrl == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(
          driver.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(driver.phoneNumber),
            Row(
              children: [
                StatusIndicator(status: driver.status),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${driver.rating.toStringAsFixed(1)}'),
                  ],
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}