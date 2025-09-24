import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/mock_api_client.dart';
import '../services/signalr_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final MockApiClient mockApiClient;
  final SignalRService signalRService;

  AppUser? _currentUser;
  bool _loading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider({ApiClient? apiClient, SignalRService? signalRService})
    : apiClient = apiClient ?? ApiClient(),
      mockApiClient = MockApiClient(),
      signalRService = signalRService ?? SignalRService();

  // Login with email and password
  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Use mock API for authentication
      final response = await mockApiClient.login(email, password);
      _currentUser = response.user;
      // Skip SignalR connection for mock authentication
      // await signalRService.connect(
      //   role: response.user.role,
      //   userId: response.user.id,
      // );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Sign up with email and password
  Future<void> signup({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'customer',
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Use mock API for user creation
      final response = await mockApiClient.signup(
        AuthRequest(
          email: email,
          password: password,
          name: name,
          phone: phone,
          role: role,
        ),
      );

      _currentUser = response.user;
      // Skip SignalR connection for mock authentication
      // await signalRService.connect(
      //   role: response.user.role,
      //   userId: response.user.id,
      // );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Skip SignalR disconnect for mock authentication
      // await signalRService.disconnect();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
