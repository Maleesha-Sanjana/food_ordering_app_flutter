import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/order.dart';
import '../models/payment.dart';

class CartLine {
  final FoodItem item;
  int quantity;
  String type; // retail | wholesale

  CartLine({required this.item, this.quantity = 1, this.type = 'retail'});

  double get lineTotal {
    if (type == 'wholesale' &&
        item.isWholesaleAvailable &&
        item.wholesalePrice != null) {
      return item.wholesalePrice! * quantity;
    }
    return item.retailPrice * quantity;
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartLine> _lines = [];
  double _discount = 0.0;
  PaymentMethod? _selectedPaymentMethod;

  List<CartLine> get lines => List.unmodifiable(_lines);
  double get subtotal => _lines.fold(0.0, (sum, l) => sum + l.lineTotal);
  double get discount => _discount;
  double get grandTotal => subtotal - discount;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;

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
    final initialLength = _lines.length;
    _lines.removeWhere((l) => l.item.id == item.id && l.type == type);

    // Only notify listeners if something was actually removed
    if (_lines.length != initialLength) {
      notifyListeners();
    }
  }

  void updateQuantity(
    FoodItem item,
    int newQuantity, {
    String type = 'retail',
  }) {
    try {
      final line = _lines.firstWhere(
        (l) => l.item.id == item.id && l.type == type,
      );

      if (newQuantity <= 0) {
        remove(item, type: type);
      } else {
        line.quantity = newQuantity;
        notifyListeners();
      }
    } catch (e) {
      // If item not found and quantity > 0, add it to cart
      if (newQuantity > 0) {
        add(item, type: type);
        // Set the quantity after adding
        final line = _lines.firstWhere(
          (l) => l.item.id == item.id && l.type == type,
        );
        line.quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  void incrementQuantity(FoodItem item, {String type = 'retail'}) {
    try {
      final line = _lines.firstWhere(
        (l) => l.item.id == item.id && l.type == type,
      );
      line.quantity++;
      notifyListeners();
    } catch (e) {
      // If item not found, add it to cart
      add(item, type: type);
    }
  }

  void decrementQuantity(FoodItem item, {String type = 'retail'}) {
    try {
      final line = _lines.firstWhere(
        (l) => l.item.id == item.id && l.type == type,
      );

      if (line.quantity > 1) {
        line.quantity--;
        notifyListeners();
      } else {
        remove(item, type: type);
      }
    } catch (e) {
      // If item not found, do nothing
      print('Item not found in cart: ${e.toString()}');
    }
  }

  void clear() {
    _lines.clear();
    _discount = 0.0;
    _selectedPaymentMethod = null;
    notifyListeners();
  }

  void applyDiscount(double value) {
    _discount = value;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod paymentMethod) {
    _selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }

  void clearPaymentMethod() {
    _selectedPaymentMethod = null;
    notifyListeners();
  }

  bool get hasValidPayment =>
      _selectedPaymentMethod != null && _selectedPaymentMethod!.isValid;

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
