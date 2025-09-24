import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../services/mock_api_client.dart';

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

  // Local state for managing users
  List<Map<String, dynamic>> _localUsers = [];

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
    _initializeUsers();
  }

  void _initializeUsers() {
    // Initialize with mock users from the API client
    _localUsers = [
      {
        'id': 1,
        'name': 'Customer User',
        'email': 'customer@gmail.com',
        'role': 'customer',
        'phone': '+1 (555) 123-4567',
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      },
      {
        'id': 2,
        'name': 'Seller User',
        'email': 'seller@gmail.com',
        'role': 'seller',
        'phone': '+1 (555) 987-6543',
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 15)),
      },
      {
        'id': 3,
        'name': 'Admin User',
        'email': 'admin@gmail.com',
        'role': 'admin',
        'phone': '+1 (555) 456-7890',
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': 4,
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'role': 'customer',
        'phone': '+1 (555) 111-2222',
        'isActive': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 10)),
      },
      {
        'id': 5,
        'name': 'Jane Smith',
        'email': 'jane.smith@example.com',
        'role': 'seller',
        'phone': '+1 (555) 333-4444',
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
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
                              IconButton(
                                onPressed: () async {
                                  final auth = context.read<AuthProvider>();
                                  await auth.logout();
                                  if (mounted) {
                                Navigator.of(context).pushReplacementNamed('/');
                                  }
                                },
                                icon: Icon(
                                  Icons.logout,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                                ),
                                tooltip: 'Logout',
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
                  () {
                    setState(() {
                      _selectedTab = 'Accounts';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  theme,
                  'View Order Details',
                  Icons.list_alt,
                  theme.colorScheme.secondary,
                  () {
                    setState(() {
                      _selectedTab = 'Orders';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  theme,
                  'Manage Accounts',
                  Icons.admin_panel_settings,
                  theme.colorScheme.tertiary,
                  () {
                    setState(() {
                      _selectedTab = 'Accounts';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  theme,
                  'System Settings',
                  Icons.settings,
                  theme.colorScheme.error,
                  () {
                    // TODO: Implement system settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('System settings coming soon!'),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    );
                  },
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
    if (orders.orders.isEmpty) {
      return Center(
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
      );
    }

    // Group orders by seller
    final Map<int, List<OrderModel>> ordersBySeller = {};
    for (final order in orders.orders) {
      ordersBySeller.putIfAbsent(order.sellerId, () => []).add(order);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: ordersBySeller.length,
      itemBuilder: (context, index) {
        final sellerId = ordersBySeller.keys.elementAt(index);
        final sellerOrders = ordersBySeller[sellerId]!;
        final totalRevenue = sellerOrders.fold(
          0.0,
          (sum, order) => sum + order.grandTotal,
        );
        final pendingCount = sellerOrders
            .where((o) => o.orderStatus == 'Pending')
            .length;
        final completedCount = sellerOrders
            .where((o) => o.orderStatus == 'Completed')
            .length;

        return _buildSellerOrderGroup(
          context,
          theme,
          sellerId,
          sellerOrders,
          totalRevenue,
          pendingCount,
          completedCount,
        );
      },
    );
  }

  Widget _buildAccountsTab(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Management Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Account Management',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage users, roles, and permissions across the platform',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // User Management Section
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Users List
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            'Role',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            'Status',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            'Actions',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Real users from local data
                  ..._localUsers.map((user) {
                    final role = user['role'] as String;
                    final isActive = user['isActive'] as bool;
                    final index = _localUsers.indexOf(user);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // User Info
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
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
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['name'] as String,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        user['email'] as String,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Role
                          SizedBox(
                            width: 80,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: role == 'admin'
                                      ? theme.colorScheme.errorContainer
                                      : role == 'seller'
                                      ? theme.colorScheme.secondaryContainer
                                      : theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: TextStyle(
                                    color: role == 'admin'
                                        ? theme.colorScheme.onErrorContainer
                                        : role == 'seller'
                                        ? theme.colorScheme.onSecondaryContainer
                                        : theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),

                          // Status
                          SizedBox(
                            width: 90,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isActive
                                          ? Icons.check_circle
                                          : Icons.block,
                                      size: 12,
                                      color: isActive
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onErrorContainer,
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        isActive ? 'Active' : 'Suspended',
                                        style: TextStyle(
                                          color: isActive
                                              ? theme
                                                    .colorScheme
                                                    .onPrimaryContainer
                                              : theme
                                                    .colorScheme
                                                    .onErrorContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Actions
                          SizedBox(
                            width: 60,
                            child: Center(
                              child: PopupMenuButton<String>(
                                onSelected: (value) => _handleUserAction(
                                  context,
                                  theme,
                                  index,
                                  value,
                                ),
                                icon: Icon(
                                  Icons.more_vert,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  size: 20,
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
                                  PopupMenuItem(
                                    value: 'suspend',
                                    child: Row(
                                      children: [
                                        Icon(Icons.block),
                                        const SizedBox(width: 8),
                                        Text(isActive ? 'Suspend' : 'Activate'),
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
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
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
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
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

  Widget _buildSellerOrderGroup(
    BuildContext context,
    ThemeData theme,
    int sellerId,
    List<OrderModel> sellerOrders,
    double totalRevenue,
    int pendingCount,
    int completedCount,
  ) {
    final mockApiClient = MockApiClient();
    final sellerName = mockApiClient.getSellerName(sellerId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondary,
                  child: Icon(
                    Icons.store,
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellerName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${sellerOrders.length} orders • \$${totalRevenue.toStringAsFixed(2)} total',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicators
                Row(
                  children: [
                    if (pendingCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pendingCount Pending',
                          style: TextStyle(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (completedCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$completedCount Completed',
                          style: TextStyle(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Orders List
          ...sellerOrders
              .map(
                (order) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _buildOrderCard(context, order, theme),
                ),
              )
              .toList(),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    ThemeData theme,
  ) {
    final mockApiClient = MockApiClient();
    final customerName = mockApiClient.getCustomerName(order.customerId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
          'Customer: $customerName | \$${order.grandTotal.toStringAsFixed(2)}',
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

  void _showCreateUserDialog(BuildContext context, ThemeData theme) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedRole = 'customer';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New User'),
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
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'customer',
                        child: Text('Customer'),
                      ),
                      DropdownMenuItem(value: 'seller', child: Text('Seller')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
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
                  final newUser = {
                    'id': _localUsers.length + 1,
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'role': selectedRole,
                    'phone': phoneController.text.trim(),
                    'isActive': true,
                    'createdAt': DateTime.now(),
                  };

                  setState(() {
                    _localUsers.add(newUser);
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${newUser['name']} created successfully!'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                }
              },
              child: const Text('Create User'),
            ),
          ],
        ),
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
    final user = _localUsers[index];
    String selectedRole = user['role'] as String;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${user['name']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current Role: ${user['role'].toString().toUpperCase()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select New Role',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'customer',
                        child: Text('Customer'),
                      ),
                      DropdownMenuItem(value: 'seller', child: Text('Seller')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a role';
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
                  setState(() {
                    _localUsers[index]['role'] = selectedRole;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${user['name']} role updated to ${selectedRole.toUpperCase()}',
                      ),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                }
              },
              child: const Text('Update Role'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuspendUserDialog(
    BuildContext context,
    ThemeData theme,
    int index,
  ) {
    final user = _localUsers[index];
    final isActive = user['isActive'] as bool;
    final action = isActive ? 'Suspend' : 'Activate';
    final actionColor = isActive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action ${user['name']}?'),
        content: Text(
          isActive
              ? 'Are you sure you want to suspend this user? They will not be able to access the system.'
              : 'Are you sure you want to activate this user? They will regain access to the system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _localUsers[index]['isActive'] = !isActive;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${user['name']} has been ${isActive ? 'suspended' : 'activated'}',
                  ),
                  backgroundColor: actionColor,
                ),
              );
            },
            child: Text(action, style: TextStyle(color: actionColor)),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, ThemeData theme, int index) {
    final user = _localUsers[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${user['name']}?'),
        content: Text(
          'Are you sure you want to permanently delete ${user['name']}? This action cannot be undone and will remove all their data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _localUsers.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user['name']} has been deleted'),
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
