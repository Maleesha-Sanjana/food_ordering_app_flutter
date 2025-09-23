import '../models/user.dart';
import '../models/food_item.dart';
import '../models/order.dart';

class MockApiClient {
  // Mock users database
  static final List<AppUser> _mockUsers = [
    const AppUser(
      id: 1,
      email: 'customer@foodhub.com',
      role: 'customer',
      name: 'John Customer',
      phone: '+1 (555) 123-4567',
    ),
    const AppUser(
      id: 2,
      email: 'seller@foodhub.com',
      role: 'seller',
      name: 'Sarah Restaurant',
      phone: '+1 (555) 987-6543',
    ),
    const AppUser(
      id: 3,
      email: 'admin@foodhub.com',
      role: 'admin',
      name: 'Admin User',
      phone: '+1 (555) 456-7890',
    ),
    const AppUser(
      id: 4,
      email: 'john@foodhub.com',
      role: 'customer',
      name: 'John Doe',
      phone: '+1 (555) 111-2222',
    ),
    const AppUser(
      id: 5,
      email: 'sarah@foodhub.com',
      role: 'customer',
      name: 'Sarah Smith',
      phone: '+1 (555) 333-4444',
    ),
  ];

  // Mock passwords (in real app, these would be hashed)
  static final Map<String, String> _mockPasswords = {
    'customer@foodhub.com': 'customer123',
    'seller@foodhub.com': 'seller123',
    'admin@foodhub.com': 'admin123',
    'john@foodhub.com': 'password123',
    'sarah@foodhub.com': 'password123',
  };

  // Mock food items
  static final List<FoodItem> _mockFoodItems = [
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
    const FoodItem(
      id: 4,
      name: 'Pasta Carbonara',
      description: 'Creamy pasta with bacon and parmesan cheese',
      retailPrice: 14.99,
      sellerId: 2,
    ),
    const FoodItem(
      id: 5,
      name: 'Chocolate Cake',
      description: 'Rich chocolate cake with vanilla ice cream',
      retailPrice: 6.99,
      sellerId: 2,
    ),
  ];

  // Mock orders
  static final List<OrderModel> _mockOrders = [
    OrderModel(
      id: 1,
      customerId: 1,
      sellerId: 2,
      items: const [
        OrderItem(foodItemId: 1, quantity: 2, type: 'retail'),
        OrderItem(foodItemId: 2, quantity: 1, type: 'retail'),
      ],
      subtotal: 35.97,
      discount: 2.00,
      grandTotal: 33.97,
      paymentStatus: 'Paid',
      orderStatus: 'Pending',
    ),
    OrderModel(
      id: 2,
      customerId: 4,
      sellerId: 2,
      items: const [
        OrderItem(foodItemId: 3, quantity: 1, type: 'retail'),
        OrderItem(foodItemId: 5, quantity: 2, type: 'retail'),
      ],
      subtotal: 22.48,
      discount: 1.00,
      grandTotal: 21.48,
      paymentStatus: 'Paid',
      orderStatus: 'Accepted',
    ),
  ];

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock login
  Future<AuthResponse> login(String email, String password) async {
    await _simulateDelay();
    
    final user = _mockUsers.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );
    
    final storedPassword = _mockPasswords[email];
    if (storedPassword != password) {
      throw Exception('Invalid password');
    }
    
    // Generate a mock token
    final token = 'mock_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    return AuthResponse(user: user, token: token);
  }

  // Mock signup
  Future<AuthResponse> signup(AuthRequest request) async {
    await _simulateDelay();
    
    // Check if user already exists
    if (_mockUsers.any((user) => user.email == request.email)) {
      throw Exception('User already exists');
    }
    
    // Create new user
    final newUser = AppUser(
      id: _mockUsers.length + 1,
      email: request.email,
      role: request.role ?? 'customer',
      name: request.name,
      phone: request.phone,
      createdAt: DateTime.now(),
    );
    
    // Add to mock database
    _mockUsers.add(newUser);
    _mockPasswords[request.email] = request.password;
    
    // Generate a mock token
    final token = 'mock_token_${newUser.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    return AuthResponse(user: newUser, token: token);
  }

  // Mock get food items
  Future<List<FoodItem>> getFoodItems() async {
    await _simulateDelay();
    return List.from(_mockFoodItems);
  }

  // Mock create order
  Future<OrderModel> createOrder(Map<String, dynamic> payload) async {
    await _simulateDelay();
    
    final newOrder = OrderModel(
      id: _mockOrders.length + 1,
      customerId: payload['customerId'] as int,
      sellerId: payload['sellerId'] as int,
      items: (payload['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      subtotal: payload['subtotal'] as double,
      discount: payload['discount'] as double,
      grandTotal: payload['grandTotal'] as double,
      paymentStatus: payload['paymentStatus'] as String,
      orderStatus: payload['orderStatus'] as String,
    );
    
    _mockOrders.add(newOrder);
    return newOrder;
  }

  // Mock accept order
  Future<void> acceptOrder(int orderId) async {
    await _simulateDelay();
    
    final orderIndex = _mockOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) {
      throw Exception('Order not found');
    }
    
    final order = _mockOrders[orderIndex];
    final updatedOrder = OrderModel(
      id: order.id,
      customerId: order.customerId,
      sellerId: order.sellerId,
      items: order.items,
      subtotal: order.subtotal,
      discount: order.discount,
      grandTotal: order.grandTotal,
      paymentStatus: order.paymentStatus,
      orderStatus: 'Accepted',
    );
    
    _mockOrders[orderIndex] = updatedOrder;
  }

  // Mock identify user (for backward compatibility)
  Future<AppUser> identifyUser(String email) async {
    await _simulateDelay();
    
    final user = _mockUsers.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );
    
    return user;
  }

  // Get mock orders (for testing)
  List<OrderModel> get orders => List.from(_mockOrders);
  
  // Add a new order (for testing)
  void addOrder(OrderModel order) {
    _mockOrders.add(order);
  }
}
