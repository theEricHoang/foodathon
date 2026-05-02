import 'dart:io';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import 'package:uuid/uuid.dart';

class RestaurantRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  static const _restaurantsCollection = 'restaurants';
  static const _menuItemsSubcollection = 'menuItems';

  RestaurantRepository({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;
  
  Future<List<Restaurant>> fetchRestaurants() {
    return _firestoreService.getCollection(_restaurantsCollection).then((docs) {
      return docs.map((doc) => Restaurant.fromJson(doc)).toList();
    });
  }

  Future<Restaurant?> fetchRestaurant(String restaurantId) async {
    final data = await _firestoreService.getDocument(_restaurantsCollection, restaurantId);
    if (data == null) return null;
    return Restaurant.fromJson(data);
  }

  Future<Restaurant?> fetchRestaurantByOwnerId(String ownerId) async {
    final docs = await _firestoreService.queryCollection(
      _restaurantsCollection,
      field: 'ownerId',
      value: ownerId,
    );
    if (docs.isEmpty) return null;
    return Restaurant.fromJson(docs.first);
  }

  Future<Restaurant> createRestaurant({
    required String ownerId, 
    required String name, 
    required String description, 
    required String cuisine, 
    required int priceLevel, 
    File? image}
    ) async {
      final restaurantId = Uuid().v4();
      final restaurant = Restaurant(
        id: restaurantId,
        ownerId: ownerId,
        name: name,
        description: description,
        cuisine: cuisine,
        priceLevel: priceLevel,
        rating: 0.0,
      );
      await _firestoreService.setDocument(_restaurantsCollection, restaurantId, restaurant.toJson());
      if (image != null) {
        await _storageService.uploadFile(
          'restaurants/$restaurantId/photo.jpg', 
          image,
        );
      }
      return restaurant;
    }

      

  Future<void> updateRestaurant({
    required String restaurantId, 
    String? name, 
    String? description, 
    String? cuisine, 
    int? priceLevel
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (cuisine != null) data['cuisine'] = cuisine;
    if (priceLevel != null) data['priceLevel'] = priceLevel;

    await _firestoreService.updateDocument(_restaurantsCollection, restaurantId, data);
  }
  
  Future<void> deleteRestaurant(String restaurantId) async {
    await _firestoreService.deleteDocument(_restaurantsCollection, restaurantId)
      .then((_) => _storageService.deleteFolder('restaurants/$restaurantId'));
  }

  Stream<List<Restaurant>> streamRestaurants() {
    return _firestoreService.streamCollection(_restaurantsCollection).map((docs) {
      return docs.map((doc) => Restaurant.fromJson(doc)).toList();
    });
  }

  Future<List<MenuItem>> fetchMenuItems(String restaurantId) {
    return _firestoreService.getCollection('$_restaurantsCollection/$restaurantId/$_menuItemsSubcollection').then((docs) {
      return docs.map((doc) => MenuItem.fromJson(doc)).toList();
    });
  }

  Future<MenuItem> addMenuItem({
    required String restaurantId, 
    required String name, 
    required String description, 
    required double price
  }) async {
    final menuItemId = Uuid().v4();
    final menuItem = MenuItem(
      id: menuItemId,
      restaurantId: restaurantId,
      name: name,
      description: description,
      price: price,
    );

    await _firestoreService.setSubcollectionDocument(
      _restaurantsCollection, 
      restaurantId, 
      _menuItemsSubcollection, 
      menuItemId, 
      menuItem.toJson()
    );
    return menuItem;
  }
    
  Future<void> deleteMenuItem({
    required String restaurantId, 
    required String menuItemId
  }) async {
    await _firestoreService.deleteDocument('$_restaurantsCollection/$restaurantId/$_menuItemsSubcollection', menuItemId);
  }

}