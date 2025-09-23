import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/order.dart';

class CartLine {
  final FoodItem item;
  int quantity;
  String type; // retail | wholesale

  CartLine({required this.item, this.quantity = 1, this.type = 'retail'});

  double get lineTotal => item.retailPrice * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartLine> _lines = [];
  double _discount = 0.0;

  List<CartLine> get lines => List.unmodifiable(_lines);
  double get subtotal => _lines.fold(0.0, (sum, l) => sum + l.lineTotal);
  double get discount => _discount;
  double get grandTotal => subtotal - discount;

  void add(FoodItem item, {String type = 'retail'}) {
    final existing = _lines
        .where((l) => l.item.id == item.id && l.type == type)
        .toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += 1;
    } else {
      _lines.add(CartLine(item: item, type: type));
    }
    notifyListeners();
  }

  void remove(FoodItem item, {String type = 'retail'}) {
    _lines.removeWhere((l) => l.item.id == item.id && l.type == type);
    notifyListeners();
  }

  void updateQuantity(
    FoodItem item,
    int newQuantity, {
    String type = 'retail',
  }) {
    final line = _lines.firstWhere(
      (l) => l.item.id == item.id && l.type == type,
      orElse: () => throw Exception('Item not found in cart'),
    );

    if (newQuantity <= 0) {
      remove(item, type: type);
    } else {
      line.quantity = newQuantity;
      notifyListeners();
    }
  }

  void incrementQuantity(FoodItem item, {String type = 'retail'}) {
    final line = _lines.firstWhere(
      (l) => l.item.id == item.id && l.type == type,
      orElse: () => throw Exception('Item not found in cart'),
    );
    line.quantity++;
    notifyListeners();
  }

  void decrementQuantity(FoodItem item, {String type = 'retail'}) {
    final line = _lines.firstWhere(
      (l) => l.item.id == item.id && l.type == type,
      orElse: () => throw Exception('Item not found in cart'),
    );

    if (line.quantity > 1) {
      line.quantity--;
      notifyListeners();
    } else {
      remove(item, type: type);
    }
  }

  void clear() {
    _lines.clear();
    _discount = 0.0;
    notifyListeners();
  }

  void applyDiscount(double value) {
    _discount = value;
    notifyListeners();
  }

  List<OrderItem> toOrderItems() {
    return _lines
        .map(
          (l) => OrderItem(
            foodItemId: l.item.id,
            quantity: l.quantity,
            type: l.type,
          ),
        )
        .toList();
  }
}
