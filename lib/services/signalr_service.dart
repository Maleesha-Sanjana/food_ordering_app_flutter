import 'package:signalr_core/signalr_core.dart';
import '../config/app_config.dart';

typedef OrdersEventHandler = void Function(dynamic payload);

class SignalRService {
  HubConnection? _connection;

  Future<void> connect({required String role, required int userId}) async {
    if (_connection != null &&
        _connection!.state == HubConnectionState.connected)
      return;
    final connection = HubConnectionBuilder()
        .withUrl(
          AppConfig.ordersHubUrl,
          HttpConnectionOptions(transport: HttpTransportType.webSockets),
        )
        .build();

    await connection.start();
    try {
      await connection.invoke('RegisterClient', args: [role, userId]);
    } catch (_) {}
    _connection = connection;
  }

  void onNewOrder(OrdersEventHandler handler) {
    _connection?.on('NewOrderCreated', (args) => handler(args?.firstOrNull));
  }

  void onOrderAccepted(OrdersEventHandler handler) {
    _connection?.on('OrderAccepted', (args) => handler(args?.firstOrNull));
  }

  Future<void> disconnect() async {
    final c = _connection;
    _connection = null;
    if (c != null) {
      await c.stop();
    }
  }

  Future<void> dispose() async {
    await disconnect();
  }
}

extension _FirstOrNull on List<Object?> {
  Object? get firstOrNull => isEmpty ? null : this[0];
}
