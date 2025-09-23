import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_client.dart';
import '../services/signalr_service.dart';

class OrdersProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final SignalRService signalRService;

  final List<OrderModel> _orders = [];
  List<OrderModel> get orders => List.unmodifiable(_orders);

  OrdersProvider({ApiClient? apiClient, SignalRService? signalRService})
    : apiClient = apiClient ?? ApiClient(),
      signalRService = signalRService ?? SignalRService();

  void attachHubHandlers() {
    signalRService.onNewOrder((payload) {
      // payload assumed to be a map
      if (payload is Map) {
        final map = Map<String, dynamic>.from(payload as Map);
        _orders.insert(0, OrderModel.fromJson(map));
        notifyListeners();
      }
    });

    signalRService.onOrderAccepted((payload) {
      if (payload is Map) {
        final map = Map<String, dynamic>.from(payload as Map);
        final id = map['id'] as int?;
        if (id != null) {
          final idx = _orders.indexWhere((o) => o.id == id);
          if (idx != -1) {
            final old = _orders[idx];
            _orders[idx] = OrderModel(
              id: old.id,
              customerId: old.customerId,
              sellerId: old.sellerId,
              items: old.items,
              subtotal: old.subtotal,
              discount: old.discount,
              grandTotal: old.grandTotal,
              paymentStatus: old.paymentStatus,
              orderStatus: 'Accepted',
            );
            notifyListeners();
          }
        }
      }
    });
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    final created = await apiClient.createOrder(order.toJson());
    _orders.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<void> acceptOrder(int orderId) async {
    await apiClient.acceptOrder(orderId);
  }
}
