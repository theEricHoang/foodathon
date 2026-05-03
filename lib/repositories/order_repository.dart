import "../../models/order.dart";
import "../../models/order_item.dart";
import "package:uuid/uuid.dart";
import "../services/firestore_service.dart";

class OrderRepository {
  final FirestoreService _firestoreService;

  static const _collection = 'orders';

  OrderRepository({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;
  
  Future<Order> createOrder({
    required String customerId, 
    required String customerName, 
    required String restaurantId, 
    required String restaurantName, 
    required List<OrderItem> items, 
    required double total}
    ) {
      final orderId = Uuid().v4();
      final order = Order(
        id: orderId,
        customerId: customerId,
        customerName: customerName,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: items,
        total: total,
        status: OrderStatus.sent,
        createdAt: DateTime.now(),
      );
      return _firestoreService
        .setDocument(_collection, orderId, order.toJson())
        .then((_) => order);    
    }
  
  Future<Order?> fetchOrder(String orderId) {
    return _firestoreService
      .getDocument(_collection, orderId)
      .then((data) => data != null ? Order.fromJson(data) : null);
  }

  Future<void> updateOrderStatus({
    required String orderId, 
    required OrderStatus status}
    ) {
      return _firestoreService.updateDocument(_collection, orderId, {
        'status': status.name,
      });
    }
  
  Future<void> assignRunner({
    required String orderId,
    required String runnerId,
    double? distanceToRestaurant,
    double? distanceToCustomer,
    double? commission,
  }) {
    final docRef = _firestoreService.docRef(_collection, orderId);
    return _firestoreService.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Order not found');
      }
      if (data['runnerId'] != null) {
        throw Exception('Order already taken');
      }
      final updateData = <String, dynamic>{
        'runnerId': runnerId,
        'distanceToRestaurant': ?distanceToRestaurant,
        'distanceToCustomer': ?distanceToCustomer,
        'commission': ?commission,
      };
      transaction.update(docRef, updateData);
    });
  }
    
  Future<void> cancelOrder(String orderId) {
    return _firestoreService.deleteDocument(_collection, orderId);
  }

  Stream<Order?> streamOrder(String orderId) {
    return _firestoreService
      .streamDocument(_collection, orderId)
      .map((data) => data != null ? Order.fromJson(data) : null);
  }

  Stream<List<Order>> streamCustomerOrders(String customerId) {
    return _firestoreService
      .streamCollection(_collection, field: 'customerId', value: customerId)
      .map((docs) => docs.map((data) => Order.fromJson(data)).toList());
  }

  Stream<List<Order>> streamRestaurantOrders(String restaurantId) {
    return _firestoreService
      .streamCollection(_collection, field: 'restaurantId', value: restaurantId)
      .map((docs) => docs.map((data) => Order.fromJson(data)).toList());
  }

  Stream<List<Order>> streamAvailableOrders() {
    return _firestoreService
      .streamCollection(_collection, field: 'runnerId', isNull: true)
      .map((docs) => docs
          .map((data) => Order.fromJson(data))
          .where((order) =>
              order.status == OrderStatus.confirmed ||
              order.status == OrderStatus.readyForPickup)
          .toList());
  }

  Future<List<Order>> fetchCustomerOrders(String customerId) {
    return _firestoreService
      .queryCollection(_collection, field: 'customerId', value: customerId)
      .then((docs) => docs.map((data) => Order.fromJson(data)).toList());
  }
}