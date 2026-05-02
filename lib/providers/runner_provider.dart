import 'package:flutter/foundation.dart';

import 'dart:async';

import '../repositories/runner_repository.dart';
import '../models/runner.dart';

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
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goOnline() async {
    if (_currentRunner == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _runnerRepository.goOnline(_currentRunner!.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goOffline() async {
    if (_currentRunner == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _runnerRepository.goOffline(_currentRunner!.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      _errorMessage = e.toString();
      notifyListeners();
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
    _availableRunnersSubscription?.cancel();
    _availableRunnersSubscription =
        _runnerRepository.streamAvailableRunners().listen(
      (runners) {
        _availableRunners = runners;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
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
        _runnerRepository.streamRunner(runnerId).listen(
      (runner) {
        _currentRunner = runner;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _runnerSubscription?.cancel();
    _availableRunnersSubscription?.cancel();
    super.dispose();
  }
}
