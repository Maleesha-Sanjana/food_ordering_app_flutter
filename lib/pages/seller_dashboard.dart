import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Seller')),
      body: ListView.builder(
        itemCount: orders.orders.length,
        itemBuilder: (context, i) {
          final order = orders.orders[i];
          if (order.orderStatus != 'Pending') return const SizedBox.shrink();
          return ListTile(
            title: Text('Order #${order.id}'),
            subtitle: Text('Total: ${order.grandTotal.toStringAsFixed(2)}'),
            trailing: ElevatedButton(
              onPressed: () => orders.acceptOrder(order.id),
              child: const Text('Accept'),
            ),
          );
        },
      ),
    );
  }
}


