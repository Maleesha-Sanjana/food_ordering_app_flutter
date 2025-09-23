import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedTab = 'Overview';

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final catalog = context.watch<CatalogProvider>();
    final theme = Theme.of(context);

    // Calculate statistics
    final totalOrders = orders.orders.length;
    final totalRevenue = orders.orders.fold(
      0.0,
      (sum, order) => sum + order.grandTotal,
    );
    final pendingOrders = orders.orders
        .where((order) => order.orderStatus == 'Pending')
        .length;
    final completedOrders = orders.orders
        .where((order) => order.orderStatus == 'Completed')
        .length;
    final totalItems = catalog.items.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.errorContainer.withOpacity(0.1),
              theme.colorScheme.primaryContainer.withOpacity(0.1),
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
                            backgroundColor: theme.colorScheme.error,
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: theme.colorScheme.onError,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Dashboard',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'System overview and management',
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
                                  'Live Data',
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
                      // Tab Bar
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Overview', 'Orders', 'Accounts'].map((
                            tab,
                          ) {
                            final isSelected = _selectedTab == tab;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(tab),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTab = tab;
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
                  child: _selectedTab == 'Overview'
                      ? _buildOverviewTab(
                          context,
                          theme,
                          totalOrders,
                          totalRevenue,
                          pendingOrders,
                          completedOrders,
                          totalItems,
                        )
                      : _selectedTab == 'Orders'
                      ? _buildOrdersTab(context, theme, orders)
                      : _buildAccountsTab(context, theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    ThemeData theme,
    int totalOrders,
    double totalRevenue,
    int pendingOrders,
    int completedOrders,
    int totalItems,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Total Orders',
                  totalOrders.toString(),
                  Icons.shopping_cart,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Revenue',
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Pending',
                  pendingOrders.toString(),
                  Icons.schedule,
                  theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Items',
                  totalItems.toString(),
                  Icons.restaurant_menu,
                  theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  theme,
                  'Manage Users',
                  Icons.people,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  theme,
                  'View Reports',
                  Icons.assessment,
                  theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(
    BuildContext context,
    ThemeData theme,
    OrdersProvider orders,
  ) {
    return orders.orders.isEmpty
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
            itemCount: orders.orders.length,
            itemBuilder: (context, i) {
              final order = orders.orders[i];
              return _buildOrderCard(context, order, theme);
            },
          );
  }

  Widget _buildAccountsTab(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Management Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'User Management',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateUserDialog(context, theme),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Create User'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sample users for demo
                  ...List.generate(5, (index) {
                    final roles = ['customer', 'seller', 'admin'];
                    final role = roles[index % 3];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: role == 'admin'
                              ? theme.colorScheme.error
                              : role == 'seller'
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                          child: Icon(
                            role == 'admin'
                                ? Icons.admin_panel_settings
                                : role == 'seller'
                                ? Icons.store
                                : Icons.person,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        title: Text('User ${index + 1}'),
                        subtitle: Text('user${index + 1}@foodhub.com'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(role.toUpperCase()),
                              backgroundColor: role == 'admin'
                                  ? theme.colorScheme.errorContainer
                                  : role == 'seller'
                                  ? theme.colorScheme.secondaryContainer
                                  : theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: role == 'admin'
                                    ? theme.colorScheme.onErrorContainer
                                    : role == 'seller'
                                    ? theme.colorScheme.onSecondaryContainer
                                    : theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (value) => _handleUserAction(
                                context,
                                theme,
                                index,
                                value,
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit Role'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'suspend',
                                  child: Row(
                                    children: [
                                      Icon(Icons.block),
                                      SizedBox(width: 8),
                                      Text('Suspend'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Role Management Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role Management',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role statistics
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          context,
                          theme,
                          'Customers',
                          '45',
                          Icons.person,
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRoleCard(
                          context,
                          theme,
                          'Sellers',
                          '8',
                          Icons.store,
                          theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRoleCard(
                          context,
                          theme,
                          'Admins',
                          '2',
                          Icons.admin_panel_settings,
                          theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: order.orderStatus == 'Pending'
              ? theme.colorScheme.tertiary
              : order.orderStatus == 'Accepted'
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
          child: Icon(
            order.orderStatus == 'Pending'
                ? Icons.schedule
                : order.orderStatus == 'Accepted'
                ? Icons.check_circle
                : Icons.done_all,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        title: Text('Order #${order.id}'),
        subtitle: Text(
          'Customer: ${order.customerId} | \$${order.grandTotal.toStringAsFixed(2)}',
        ),
        trailing: Chip(
          label: Text(order.orderStatus),
          backgroundColor: order.orderStatus == 'Pending'
              ? theme.colorScheme.tertiaryContainer
              : order.orderStatus == 'Accepted'
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer,
          labelStyle: TextStyle(
            color: order.orderStatus == 'Pending'
                ? theme.colorScheme.onTertiaryContainer
                : order.orderStatus == 'Accepted'
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: const Text(
          'User creation functionality would be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(
    BuildContext context,
    ThemeData theme,
    int index,
    String action,
  ) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, theme, index);
        break;
      case 'suspend':
        _showSuspendUserDialog(context, theme, index);
        break;
      case 'delete':
        _showDeleteUserDialog(context, theme, index);
        break;
    }
  }

  void _showEditUserDialog(BuildContext context, ThemeData theme, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User ${index + 1}'),
        content: const Text(
          'User role editing functionality would be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSuspendUserDialog(
    BuildContext context,
    ThemeData theme,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suspend User ${index + 1}?'),
        content: const Text('Are you sure you want to suspend this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Suspend user logic would go here
            },
            child: Text(
              'Suspend',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, ThemeData theme, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User ${index + 1}?'),
        content: const Text(
          'Are you sure you want to permanently delete this user?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete user logic would go here
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
