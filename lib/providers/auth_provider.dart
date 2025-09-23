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

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Use mock API client for testing
      final authResponse = await mockApiClient.login(email, password);
      _currentUser = authResponse.user;
      // Skip SignalR connection for now to avoid errors
      // await signalRService.connect(
      //   role: authResponse.user.role,
      //   userId: authResponse.user.id,
      // );
    } catch (e) {
      _error = e.toString();
      print('Login error: $e'); // Debug print
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final request = AuthRequest(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: 'customer', // Default role for new signups
      );
      final authResponse = await mockApiClient.signup(request);
      _currentUser = authResponse.user;
      // Skip SignalR connection for now to avoid errors
      // await signalRService.connect(
      //   role: authResponse.user.role,
      //   userId: authResponse.user.id,
      // );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _error = null;
    // Skip SignalR disconnect for now
    // await signalRService.disconnect();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Keep the old method for backward compatibility during development
  Future<void> identifyByEmail(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await mockApiClient.identifyUser(email);
      _currentUser = user;
      // Skip SignalR connection for now
      // await signalRService.connect(role: user.role, userId: user.id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
