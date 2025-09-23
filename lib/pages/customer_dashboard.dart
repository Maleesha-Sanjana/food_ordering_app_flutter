import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../models/order.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Customer')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: catalog.items.length,
              itemBuilder: (context, i) {
                final item = catalog.items[i];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => cart.add(item),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Subtotal: ${cart.subtotal.toStringAsFixed(2)}'),
                Text('Discount: ${cart.discount.toStringAsFixed(2)}'),
                Text('Grand Total: ${cart.grandTotal.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final user = auth.currentUser;
                    if (user == null || cart.lines.isEmpty) return;
                    // In this simplified demo choose first seller id from items
                    final sellerId = cart.lines.first.item.sellerId;
                    final order = OrderModel(
                      id: 0,
                      customerId: user.id,
                      sellerId: sellerId,
                      items: cart.toOrderItems(),
                      subtotal: cart.subtotal,
                      discount: cart.discount,
                      grandTotal: cart.grandTotal,
                      paymentStatus: 'Paid',
                      orderStatus: 'Pending',
                    );
                    await context.read<OrdersProvider>().createOrder(order);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed')));
                      cart.clear();
                    }
                  },
                  child: const Text('Pay with Dummy Card & Place Order'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


