import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/catalog_provider.dart';
import '../models/order.dart';
import '../models/food_item.dart';
import '../services/mock_api_client.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'Orders';
  final MockApiClient _mockApiClient = MockApiClient();

  // Local state for managing items and discounts
  final List<FoodItem> _localItems = [];
  final List<Map<String, dynamic>> _localDiscounts = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    // Initialize catalog to load food items
    Future.microtask(() {
      context.read<CatalogProvider>().fetch();
      _initializeLocalData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeLocalData() {
    // Initialize with sample items
    _localItems.clear();
    _localItems.addAll([
      const FoodItem(
        id: 1,
        name: 'Margherita Pizza',
        description: 'Classic pizza with tomato sauce, mozzarella, and basil',
        retailPrice: 12.99,
        sellerId: 2,
      ),
      const FoodItem(
        id: 2,
        name: 'Chicken Burger',
        description: 'Juicy grilled chicken breast with lettuce and tomato',
        retailPrice: 9.99,
        sellerId: 2,
      ),
      const FoodItem(
        id: 3,
        name: 'Caesar Salad',
        description: 'Fresh romaine lettuce with caesar dressing and croutons',
        retailPrice: 8.50,
        sellerId: 2,
      ),
    ]);

    // Initialize with sample discounts
    _localDiscounts.clear();
    _localDiscounts.addAll([
      {
        'id': 1,
        'name': 'Pizza Special',
        'description': '20% off on all pizzas',
        'discountType': 'percentage',
        'value': 20.0,
        'foodItemId': 1,
        'foodItemName': 'Margherita Pizza',
        'isActive': true,
      },
      {
        'id': 2,
        'name': 'Burger Deal',
        'description': '\$2 off on chicken burgers',
        'discountType': 'fixed',
        'value': 2.0,
        'foodItemId': 2,
        'foodItemName': 'Chicken Burger',
        'isActive': false,
      },
    ]);

    setState(() {});
  }

  List<OrderModel> get filteredOrders {
    final orders = context.read<OrdersProvider>().orders;
    return orders; // Show all orders in Orders tab
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.secondary,
                            child: Icon(
                              Icons.store,
                              color: theme.colorScheme.onSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seller Dashboard',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Manage your orders',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${orders.orders.length} orders',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () async {
                                  final auth = context.read<AuthProvider>();
                                  await auth.logout();
                                  if (mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/');
                                  }
                                },
                                icon: Icon(
                                  Icons.logout,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                tooltip: 'Logout',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Orders', 'Items', 'Discounts'].map((
                            filter,
                          ) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                selectedColor:
                                    theme.colorScheme.primaryContainer,
                                checkmarkColor:
                                    theme.colorScheme.onPrimaryContainer,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content based on selected tab
                Expanded(
                  child: _selectedFilter == 'Orders'
                      ? _buildOrdersTab(context, theme, orders)
                      : _selectedFilter == 'Items'
                      ? _buildItemsTab(context, theme)
                      : _buildDiscountsTab(context, theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    OrdersProvider orders,
    ThemeData theme,
  ) {
    Color statusColor;
    IconData statusIcon;

    switch (order.orderStatus) {
      case 'Pending':
        statusColor = theme.colorScheme.tertiary;
        statusIcon = Icons.pending;
        break;
      case 'Accepted':
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.check_circle;
        break;
      case 'Completed':
        statusColor = theme.colorScheme.secondary;
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer: ${_mockApiClient.getCustomerName(order.customerId)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          order.orderStatus,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Order Items
              Text(
                'Items (${order.items.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...order.items
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${_mockApiClient.getFoodItemName(item.foodItemId)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${(_mockApiClient.getFoodItem(item.foodItemId)?.retailPrice ?? 0.0).toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (order.items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${order.items.length - 3} more items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:', style: theme.textTheme.bodyMedium),
                        Text(
                          '\$${order.subtotal.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount:', style: theme.textTheme.bodyMedium),
                        Text(
                          '\$${(order.discount ?? 0.0).toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${order.grandTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Button
              if (order.orderStatus == 'Pending') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => orders.acceptOrder(order.id),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersTab(
    BuildContext context,
    ThemeData theme,
    OrdersProvider orders,
  ) {
    final filteredOrders = orders.orders;

    return filteredOrders.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Orders will appear here when customers place them',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: filteredOrders.length,
            itemBuilder: (context, i) {
              final order = filteredOrders[i];
              return _buildOrderCard(context, order, orders, theme);
            },
          );
  }

  Widget _buildItemsTab(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Items',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddItemDialog(context, theme),
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Show local food items
          if (_localItems.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items available',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first food item to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._localItems.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fastfood,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description ?? 'No description available',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${item.retailPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            _showEditItemDialog(context, theme, item.id),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showDeleteItemDialog(context, theme, item.id),
                        icon: const Icon(Icons.delete),
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildDiscountsTab(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Discounts',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDiscountDialog(context, theme),
                icon: const Icon(Icons.local_offer),
                label: const Text('Add Discount'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Show local discounts
          if (_localDiscounts.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.local_offer,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No discounts available',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first discount to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._localDiscounts.map((discount) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withOpacity(
                        0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_offer,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  title: Text(discount['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discount['description'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'For: ${discount['foodItemName']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        discount['discountType'] == 'percentage'
                            ? '${discount['value']}% off'
                            : '\$${discount['value']} off',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: discount['isActive'],
                        onChanged: (value) {
                          setState(() {
                            discount['isActive'] = value;
                          });
                        },
                      ),
                      IconButton(
                        onPressed: () => _showEditDiscountDialog(
                          context,
                          theme,
                          discount['id'],
                        ),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteDiscountDialog(
                          context,
                          theme,
                          discount['id'],
                        ),
                        icon: const Icon(Icons.delete),
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, ThemeData theme) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g., Margherita Pizza',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g., Classic pizza with tomato sauce...',
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (\$)',
                    hintText: '12.99',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newItem = FoodItem(
                  id: _localItems.length + 1,
                  name: nameController.text,
                  description: descriptionController.text,
                  retailPrice: double.parse(priceController.text),
                  sellerId: 2,
                );
                setState(() {
                  _localItems.add(newItem);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${newItem.name} added successfully!'),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              }
            },
            child: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, ThemeData theme, int itemId) {
    final item = _localItems.firstWhere((i) => i.id == itemId);
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(
      text: item.retailPrice.toString(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (\$)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedItem = FoodItem(
                  id: item.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  retailPrice: double.parse(priceController.text),
                  sellerId: item.sellerId,
                );
                setState(() {
                  final index = _localItems.indexWhere((i) => i.id == itemId);
                  if (index != -1) {
                    _localItems[index] = updatedItem;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${updatedItem.name} updated successfully!'),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              }
            },
            child: const Text('Update Item'),
          ),
        ],
      ),
    );
  }

  void _showDeleteItemDialog(
    BuildContext context,
    ThemeData theme,
    int itemId,
  ) {
    final item = _localItems.firstWhere((i) => i.id == itemId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${item.name}?'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _localItems.removeWhere((i) => i.id == itemId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} deleted successfully!'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDiscountDialog(BuildContext context, ThemeData theme) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final valueController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String discountType = 'percentage';
    int? selectedFoodItemId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Discount'),
          contentPadding: const EdgeInsets.all(24),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Discount Name',
                      hintText: 'e.g., Pizza Special',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter discount name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'e.g., 20% off on all pizzas',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select Food Item',
                    ),
                    value: selectedFoodItemId,
                    items: _localItems.map((item) {
                      return DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedFoodItemId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a food item';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Discount Type',
                    ),
                    value: discountType,
                    items: const [
                      DropdownMenuItem(
                        value: 'percentage',
                        child: Text('Percentage (%)'),
                      ),
                      DropdownMenuItem(
                        value: 'fixed',
                        child: Text('Fixed Amount (\$)'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        discountType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: valueController,
                    decoration: InputDecoration(
                      labelText: discountType == 'percentage'
                          ? 'Percentage'
                          : 'Amount (\$)',
                      hintText: discountType == 'percentage' ? '20' : '5.00',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter value';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final selectedItem = _localItems.firstWhere(
                    (i) => i.id == selectedFoodItemId,
                  );
                  final newDiscount = {
                    'id': _localDiscounts.length + 1,
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'discountType': discountType,
                    'value': double.parse(valueController.text),
                    'foodItemId': selectedFoodItemId,
                    'foodItemName': selectedItem.name,
                    'isActive': true,
                  };
                  setState(() {
                    _localDiscounts.add(newDiscount);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${newDiscount['name']} added successfully!',
                      ),
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  );
                }
              },
              child: const Text('Add Discount'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDiscountDialog(
    BuildContext context,
    ThemeData theme,
    int discountId,
  ) {
    final discount = _localDiscounts.firstWhere((d) => d['id'] == discountId);
    final nameController = TextEditingController(text: discount['name']);
    final descriptionController = TextEditingController(
      text: discount['description'],
    );
    final valueController = TextEditingController(
      text: discount['value'].toString(),
    );
    final formKey = GlobalKey<FormState>();
    String discountType = discount['discountType'];
    int? selectedFoodItemId = discount['foodItemId'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${discount['name']}'),
          contentPadding: const EdgeInsets.all(24),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Discount Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter discount name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select Food Item',
                    ),
                    value: selectedFoodItemId,
                    items: _localItems.map((item) {
                      return DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedFoodItemId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a food item';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Discount Type',
                    ),
                    value: discountType,
                    items: const [
                      DropdownMenuItem(
                        value: 'percentage',
                        child: Text('Percentage (%)'),
                      ),
                      DropdownMenuItem(
                        value: 'fixed',
                        child: Text('Fixed Amount (\$)'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        discountType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: valueController,
                    decoration: InputDecoration(
                      labelText: discountType == 'percentage'
                          ? 'Percentage'
                          : 'Amount (\$)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter value';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final selectedItem = _localItems.firstWhere(
                    (i) => i.id == selectedFoodItemId,
                  );
                  final updatedDiscount = {
                    'id': discount['id'],
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'discountType': discountType,
                    'value': double.parse(valueController.text),
                    'foodItemId': selectedFoodItemId,
                    'foodItemName': selectedItem.name,
                    'isActive': discount['isActive'],
                  };
                  setState(() {
                    final index = _localDiscounts.indexWhere(
                      (d) => d['id'] == discountId,
                    );
                    if (index != -1) {
                      _localDiscounts[index] = updatedDiscount;
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${updatedDiscount['name']} updated successfully!',
                      ),
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  );
                }
              },
              child: const Text('Update Discount'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDiscountDialog(
    BuildContext context,
    ThemeData theme,
    int discountId,
  ) {
    final discount = _localDiscounts.firstWhere((d) => d['id'] == discountId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${discount['name']}?'),
        content: const Text(
          'Are you sure you want to delete this discount? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _localDiscounts.removeWhere((d) => d['id'] == discountId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${discount['name']} deleted successfully!'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
