import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../services/messaging_service.dart';
import 'user_provider.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  final UserProvider _userProvider;
  final MessagingService _messagingService;

  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required UserRepository userRepository,
    required UserProvider userProvider,
    required MessagingService messagingService,
  })  : _userRepository = userRepository,
        _userProvider = userProvider,
        _messagingService = messagingService;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _saveFcmToken(String uid) async {
    try {
      final token = await _messagingService.getToken();
      if (token != null) {
        await _userRepository.saveFcmToken(uid, token);
      }
      _messagingService.onTokenRefresh((newToken) {
        _userRepository.saveFcmToken(uid, newToken);
      });
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepository.signIn(
        email: email,
        password: password,
      );
      _userProvider.setUser(user);
      await _saveFcmToken(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepository.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      _userProvider.setUser(user);
      await _saveFcmToken(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _userRepository.currentUser?.uid;
      if (uid != null) {
        await _userRepository.deleteFcmToken(uid);
      }
      await _userRepository.signOut();
      _userProvider.clearUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthState() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final firebaseUser = _userRepository.currentUser;
      if (firebaseUser == null) return;

      final user = await _userRepository.fetchUser(firebaseUser.uid);
      if (user != null) {
        _userProvider.setUser(user);
        await _saveFcmToken(user.id);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
