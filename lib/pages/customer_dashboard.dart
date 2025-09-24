import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/auth_provider.dart';
import '../models/food_item.dart';
import 'payment_page.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    // Initialize catalog to load food items immediately
    _loadCatalog();
  }

  void _loadCatalog() async {
    try {
      await context.read<CatalogProvider>().fetch();
    } catch (e) {
      print('Customer Dashboard: Error loading catalog: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<FoodItem> _getFilteredItems(List<FoodItem> items) {
    if (_searchQuery.isEmpty) return items;
    final filtered = items
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (item.description?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    // Debug information
    if (catalog.items.isEmpty && !catalog.loading) {
      print(
        'Customer Dashboard - No items loaded, catalog loading: ${catalog.loading}',
      );
    }

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                    ),
                                    Text(
                                      auth.currentUser?.name ??
                                          auth.currentUser?.email ??
                                          'Customer',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () =>
                                      _showCartModal(context, cart, theme),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart,
                                          color: theme.colorScheme.primary,
                                        ),
                                        if (cart.lines.isNotEmpty)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.error,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Text(
                                                '${cart.lines.length}',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.onError,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
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
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for food...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Food Items Grid
                Expanded(
                  child: catalog.loading
                      ? const Center(child: CircularProgressIndicator())
                      : _getFilteredItems(catalog.items).isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                catalog.items.isEmpty
                                    ? 'No food items available'
                                    : 'No items found',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: _getFilteredItems(catalog.items).length,
                          itemBuilder: (context, i) {
                            final item = _getFilteredItems(catalog.items)[i];
                            return _buildFoodCard(context, item, cart, theme);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: cart.lines.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cart Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                          '${cart.lines.length} items',
                          style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                        ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${cart.grandTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (cart.lines.isEmpty) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PaymentPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Proceed to Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _showCartModal(
    BuildContext context,
    CartProvider cart,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shopping Cart',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (cart.lines.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Discount Information Banner
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Automatic discounts: 5% off \$20+, 10% off \$30+, 15% off \$50+',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cart.lines.length,
                  itemBuilder: (context, index) {
                    final line = cart.lines[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.fastfood,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(line.item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.type == 'wholesale' &&
                                      line.item.isWholesaleAvailable &&
                                      line.item.wholesalePrice != null
                                  ? 'Wholesale: \$${line.item.wholesalePrice!.toStringAsFixed(2)} each'
                                  : 'Retail: \$${line.item.retailPrice.toStringAsFixed(2)} each',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: line.type == 'wholesale'
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Total: \$${line.lineTotal.toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 120,
                          child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                  cart.decrementQuantity(
                                    line.item,
                                    type: line.type,
                                  );
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                                iconSize: 20,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                            ),
                            Text('${line.quantity}'),
                            IconButton(
                              onPressed: () {
                                  cart.incrementQuantity(
                                    line.item,
                                    type: line.type,
                                  );
                              },
                              icon: const Icon(Icons.add_circle_outline),
                                iconSize: 20,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                            ),
                            IconButton(
                              onPressed: () {
                                  cart.remove(line.item, type: line.type);
                              },
                              icon: const Icon(Icons.delete_outline),
                              color: theme.colorScheme.error,
                                iconSize: 20,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                            ),
                          ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Subtotal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Subtotal:',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${cart.subtotal.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Discount (if any)
                    if (cart.discount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                            'Discount:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '-\$${cart.discount.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    const Divider(height: 16),

                    // Grand Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                          'Grand Total:',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${cart.grandTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PaymentPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Proceed to Payment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(
    BuildContext context,
    dynamic item,
    CartProvider cart,
    ThemeData theme,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          cart.add(item);
          _applySampleDiscounts(cart);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image Placeholder
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fastfood,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Food Name
              Expanded(
                flex: 2,
                child: Text(
                  item.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Description
              if (item.description != null)
                Expanded(
                  flex: 2,
                  child: Text(
                    item.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              // Price and Add Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Price display
                      Text(
                    'Retail: \$${item.retailPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.isWholesaleAvailable && item.wholesalePrice != null)
                    Text(
                      'Wholesale: \$${item.wholesalePrice!.toStringAsFixed(2)} (min ${item.wholesaleMinQuantity})',
                      style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Add buttons
                  Row(
                    children: [
                      if (item.isRetailAvailable)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => cart.add(item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                            ),
                            child: const Text(
                              'Retail',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      if (item.isRetailAvailable && item.isWholesaleAvailable)
                        const SizedBox(width: 8),
                      if (item.isWholesaleAvailable)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showWholesaleDialog(
                              context,
                              item,
                              cart,
                              theme,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: theme.colorScheme.onSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                            ),
                            child: const Text(
                              'Wholesale',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applySampleDiscounts(CartProvider cart) {
    // Apply sample discounts based on cart value
    final subtotal = cart.subtotal;

    if (subtotal >= 50.0) {
      // 15% discount for orders over $50
      cart.applyDiscount(subtotal * 0.15);
    } else if (subtotal >= 30.0) {
      // 10% discount for orders over $30
      cart.applyDiscount(subtotal * 0.10);
    } else if (subtotal >= 20.0) {
      // 5% discount for orders over $20
      cart.applyDiscount(subtotal * 0.05);
    } else {
      // No discount for smaller orders
      cart.applyDiscount(0.0);
    }
  }

  void _showWholesaleDialog(
    BuildContext context,
    dynamic item,
    CartProvider cart,
    ThemeData theme,
  ) {
    int quantity = item.wholesaleMinQuantity ?? 1;
    final quantityController = TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Wholesale Order - ${item.name}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(
                      0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Retail Price:',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${item.retailPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Wholesale Price:',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${item.wholesalePrice!.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Min Quantity:',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '${item.wholesaleMinQuantity}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setDialogState(() {
                      quantity =
                          int.tryParse(value) ?? item.wholesaleMinQuantity ?? 1;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:', style: theme.textTheme.titleMedium),
                      Text(
                        '\$${(item.wholesalePrice! * quantity).toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final qty =
                    int.tryParse(quantityController.text) ??
                    item.wholesaleMinQuantity ??
                    1;
                if (qty >= (item.wholesaleMinQuantity ?? 1)) {
                  // Add wholesale items to cart with wholesale type
                  for (int i = 0; i < qty; i++) {
                    cart.add(item, type: 'wholesale');
                  }
                  _applySampleDiscounts(cart);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added $qty ${item.name} (wholesale) to cart',
                      ),
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Minimum quantity for wholesale is ${item.wholesaleMinQuantity}',
                      ),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
