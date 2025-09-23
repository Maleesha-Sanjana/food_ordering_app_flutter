import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: ListView.builder(
        itemCount: orders.orders.length,
        itemBuilder: (context, i) {
          final order = orders.orders[i];
          return ListTile(
            title: Text('Order #${order.id}'),
            subtitle: Text('Status: ${order.orderStatus}'),
            trailing: Text(order.grandTotal.toStringAsFixed(2)),
          );
        },
      ),
    );
  }
}
