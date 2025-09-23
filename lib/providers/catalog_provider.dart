import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../services/api_client.dart';
import '../services/mock_api_client.dart';

class CatalogProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final MockApiClient mockApiClient;
  List<FoodItem> _items = const [];
  bool _loading = false;

  List<FoodItem> get items => _items;
  bool get loading => _loading;

  CatalogProvider({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient(),
      mockApiClient = MockApiClient();

  Future<void> fetch() async {
    _loading = true;
    notifyListeners();
    try {
      // Use mock API client for testing
      _items = await mockApiClient.getFoodItems();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
