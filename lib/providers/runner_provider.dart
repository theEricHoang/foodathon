import 'package:flutter/foundation.dart';

import 'dart:async';

import "../repositories/runner_repository.dart";
import "../models/runner.dart";

class RunnerProvider extends ChangeNotifier {
  final RunnerRepository _runnerRepository;

  Runner? _currentRunner;
  List<Runner> _availableRunners = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Runner?>? _runnerSubscription;
  StreamSubscription<List<Runner>>? _availableRunnersSubscription;

  RunnerProvider({
    required RunnerRepository runnerRepository,
  }) : _runnerRepository = runnerRepository;
  
  Runner? get currentRunner => _currentRunner;
  List<Runner> get availableRunners => _availableRunners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createRunner({required String userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final runner = await _runnerRepository.createRunner(userId: userId);
      _currentRunner = runner;
      _listenToRunner(runner.id);
    } catch (e) {
      _errorMessage = 'Failed to create runner: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRunner(String runnerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final runner = await _runnerRepository.fetchRunner(runnerId);
      _currentRunner = runner;
      if (runner != null) {
        _listenToRunner(runnerId);
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch runner: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRunnerByUserId(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final runner = await _runnerRepository.fetchRunnerByUserId(userId);
      _currentRunner = runner;
      if (runner != null) {
        _listenToRunner(runner.id);
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch runner by user ID: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goOnline() {
    if (_currentRunner == null) {
      _errorMessage = 'No runner to go online';
      notifyListeners();
      return Future.error(_errorMessage!);
    }
    return _runnerRepository.goOnline(_currentRunner!.id);
  }

  Future<void> goOffline() {
    if (_currentRunner == null) {
      _errorMessage = 'No runner to go offline';
      notifyListeners();
      return Future.error(_errorMessage!);
    }
    return _runnerRepository.goOffline(_currentRunner!.id);
  }

  
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    if (_currentRunner == null) return;

    try {
      await _runnerRepository.updateLocation(
        runnerId: _currentRunner!.id,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      _errorMessage = 'Failed to update location: $e';
    }
  }

  Future<void> deleteRunner(String runnerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _runnerSubscription?.cancel();
      _runnerSubscription = null;

      await _runnerRepository.deleteRunner(runnerId);
      _currentRunner = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void streamAvailableRunners() {
    _runnerSubscription?.cancel();
    _availableRunnersSubscription =
        _runnerRepository.streamAvailableRunners().listen((runners) {
      _availableRunners = runners;
      notifyListeners();
    });
  }

  void clearCurrentRunner() {
    _runnerSubscription?.cancel();
    _runnerSubscription = null;
    _currentRunner = null;
    notifyListeners();
  }

  void clearAvailableRunners() {
    _availableRunnersSubscription?.cancel();
    _availableRunnersSubscription = null;
    _availableRunners = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _listenToRunner(String runnerId) {
    _runnerSubscription?.cancel();
    _runnerSubscription =
        _runnerRepository.streamRunner(runnerId).listen((runner) {
      _currentRunner = runner;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _runnerSubscription?.cancel();
    _availableRunnersSubscription?.cancel();
    super.dispose();
  }
}