import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../services/api_client.dart';

class CatalogProvider extends ChangeNotifier {
  final ApiClient apiClient;
  List<FoodItem> _items = const [];
  bool _loading = false;

  List<FoodItem> get items => _items;
  bool get loading => _loading;

  CatalogProvider({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  Future<void> fetch() async {
    _loading = true;
    notifyListeners();
    try {
      _items = await apiClient.getFoodItems();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
