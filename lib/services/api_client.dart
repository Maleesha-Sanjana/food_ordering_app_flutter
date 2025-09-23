import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/food_item.dart';
import '../models/user.dart';
import '../models/order.dart';

class ApiClient {
  final String baseUrl;
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<FoodItem>> getFoodItems() async {
    final res = await http.get(_uri('/api/food-items'));
    if (res.statusCode != 200) throw Exception('Failed to fetch food items');
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppUser> identifyUser(String email) async {
    final res = await http.post(
      _uri('/api/users/identify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (res.statusCode != 200) throw Exception('Failed to identify user');
    return AppUser.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<OrderModel> createOrder(Map<String, dynamic> payload) async {
    final res = await http.post(
      _uri('/api/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create order');
    }
    return OrderModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> acceptOrder(int orderId) async {
    final res = await http.post(_uri('/api/orders/$orderId/accept'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to accept order');
    }
  }
}
