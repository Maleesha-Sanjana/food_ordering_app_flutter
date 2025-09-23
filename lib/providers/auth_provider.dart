import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/signalr_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final SignalRService signalRService;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  AuthProvider({ApiClient? apiClient, SignalRService? signalRService})
    : apiClient = apiClient ?? ApiClient(),
      signalRService = signalRService ?? SignalRService();

  Future<void> identifyByEmail(String email) async {
    final user = await apiClient.identifyUser(email);
    _currentUser = user;
    notifyListeners();
    await signalRService.connect(role: user.role, userId: user.id);
  }
}
