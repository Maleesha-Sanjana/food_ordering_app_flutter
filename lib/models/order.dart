class OrderItem {
  final int foodItemId;
  final int quantity;
  final String type; // retail | wholesale

  const OrderItem({
    required this.foodItemId,
    required this.quantity,
    required this.type,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      foodItemId: json['foodItemId'] as int,
      quantity: json['quantity'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'foodItemId': foodItemId,
    'quantity': quantity,
    'type': type,
  };
}

class OrderModel {
  final int id;
  final int customerId;
  final int sellerId;
  final List<OrderItem> items;
  final double subtotal;
  final double? discount;
  final double grandTotal;
  final String paymentStatus; // Paid
  final String orderStatus; // Pending | Accepted

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.sellerId,
    required this.items,
    required this.subtotal,
    this.discount,
    required this.grandTotal,
    required this.paymentStatus,
    required this.orderStatus,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>? ?? []);
    return OrderModel(
      id: json['id'] as int,
      customerId: json['customerId'] as int,
      sellerId: json['sellerId'] as int,
      items: itemsJson
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      orderStatus: json['orderStatus'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'sellerId': sellerId,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'grandTotal': grandTotal,
    'paymentStatus': paymentStatus,
    'orderStatus': orderStatus,
  };
}
