import 'package:flutter/foundation.dart';

import 'dart:async';
import 'dart:io';

import '../repositories/restaurant_repository.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';

class RestaurantProvider extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository;

  Restaurant? _currentRestaurant;
  List<Restaurant> _restaurants = [];
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Restaurant>>? _restaurantsSubscription;

  RestaurantProvider({
    required RestaurantRepository restaurantRepository,
  }) : _restaurantRepository = restaurantRepository;
  
  Restaurant? get currentRestaurant => _currentRestaurant;
  List<Restaurant> get restaurants => _restaurants;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createRestaurant({
    required String ownerId,
    required String name,
    required String description,
    required String cuisine,
    required int priceLevel,
    double? latitude,
    double? longitude,
    File? image
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final restaurant = await _restaurantRepository.createRestaurant(
        ownerId: ownerId,
        name: name,
        description: description,
        cuisine: cuisine,
        priceLevel: priceLevel,
        latitude: latitude,
        longitude: longitude,
        image: image,
      );
      _currentRestaurant = restaurant;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _restaurants = await _restaurantRepository.fetchRestaurants();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRestaurantByOwnerId(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentRestaurant = await _restaurantRepository.fetchRestaurantByOwnerId(ownerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRestaurant(String restaurantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentRestaurant = await _restaurantRepository.fetchRestaurant(restaurantId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRestaurant({
    required String restaurantId, 
    String? name, 
    String? description, 
    String? cuisine, 
    int? priceLevel
  }) async {
    if (_currentRestaurant == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _restaurantRepository.updateRestaurant(
        restaurantId: restaurantId,
        name: name,
        description: description,
        cuisine: cuisine,
        priceLevel: priceLevel,
      );
      await fetchRestaurant(restaurantId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRestaurant(String restaurantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _restaurantRepository.deleteRestaurant(restaurantId);
      _currentRestaurant = null;
      _menuItems = [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void streamRestaurants() {
    _restaurantsSubscription?.cancel();
    _restaurantsSubscription =
      _restaurantRepository.streamRestaurants().listen(
        (restaurants) {
          _restaurants = restaurants;
          notifyListeners();
        },
        onError: (e) {
          _errorMessage = e.toString();
          notifyListeners();
        },
      );
  }

  Future<void> fetchMenuItems(String restaurantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _menuItems = await _restaurantRepository.fetchMenuItems(restaurantId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMenuItem({
    required String restaurantId, 
    required String name, 
    required String description, 
    required double price
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _restaurantRepository.addMenuItem(
        restaurantId: restaurantId,
        name: name,
        description: description,
        price: price,
      );
      await fetchMenuItems(restaurantId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMenuItem({
    required String restaurantId, 
    required String menuItemId
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _restaurantRepository.deleteMenuItem(
        restaurantId: restaurantId,
        menuItemId: menuItemId,
      );
      await fetchMenuItems(restaurantId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCurrentRestaurant() {
    _currentRestaurant = null;
    _menuItems = [];
    notifyListeners();
  }

  void clearRestaurants() {
    _restaurantsSubscription?.cancel();
    _restaurantsSubscription = null;
    _restaurants = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _restaurantsSubscription?.cancel();
    super.dispose();
  }
}
