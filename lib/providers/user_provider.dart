import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UserModel?>? _userSubscription;

  UserProvider({required UserRepository userRepository})
      : _userRepository = userRepository;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _currentUser != null;

  void setUser(UserModel user) {
    _currentUser = user;
    _errorMessage = null;
    _listenToUser(user.id);
    notifyListeners();
  }

  void clearUser() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepository.fetchUser(uid);
      _currentUser = user;
      if (user != null) {
        _listenToUser(uid);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser({String? name, String? email}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.updateUser(
        uid: _currentUser!.id,
        name: name,
        email: email,
      );
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

  void _listenToUser(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _userRepository.streamUser(uid).listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
