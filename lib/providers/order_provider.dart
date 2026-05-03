import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/order_item.dart';
import '../repositories/order_repository.dart';
import '../services/notification_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final NotificationService _notificationService;

  Order? _currentOrder;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Order?>? _orderSubscription;
  StreamSubscription<List<Order>>? _ordersSubscription;

  OrderProvider({
    required OrderRepository orderRepository,
    required NotificationService notificationService,
  })  : _orderRepository = orderRepository,
        _notificationService = notificationService;

  Order? get currentOrder => _currentOrder;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createOrder({
    required String customerId,
    required String customerName,
    required String restaurantId,
    required String restaurantName,
    required List<OrderItem> items,
    required double total,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderRepository.createOrder(
        customerId: customerId,
        customerName: customerName,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: items,
        total: total,
      );
      _currentOrder = order;
      _listenToOrder(order.id);

      _notificationService.notifyRestaurantOwner(
        restaurantId: restaurantId,
        title: 'New Order!',
        body: 'New order from $customerName!',
        data: {'type': 'order_status_update', 'orderId': order.id},
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderRepository.fetchOrder(orderId);
      _currentOrder = order;
      if (order != null) {
        _listenToOrder(orderId);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderRepository.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      final order = _currentOrder;
      if (order != null) {
        _sendStatusNotification(order, status);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sendStatusNotification(Order order, OrderStatus status) {
    final data = {'type': 'order_status_update', 'orderId': order.id};

    switch (status) {
      case OrderStatus.confirmed:
        _notificationService.notifyCustomer(
          customerId: order.customerId,
          title: 'Order Confirmed',
          body: 'Your order has been confirmed!',
          data: data,
        );
      case OrderStatus.readyForPickup:
        _notificationService.notifyCustomer(
          customerId: order.customerId,
          title: 'Ready for Pickup',
          body: 'Your order is ready for pickup!',
          data: data,
        );
      case OrderStatus.headedToYou:
        _notificationService.notifyCustomer(
          customerId: order.customerId,
          title: 'On Its Way!',
          body: 'Your order is on its way!',
          data: data,
        );
      case OrderStatus.arrived:
        _notificationService.notifyCustomer(
          customerId: order.customerId,
          title: 'Order Arrived',
          body: 'Your order has arrived!',
          data: data,
        );
      case OrderStatus.sent:
        break;
    }
  }

  Future<void> assignRunner({
    required String orderId,
    required String runnerId,
    double? distanceToRestaurant,
    double? distanceToCustomer,
    double? commission,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderRepository.assignRunner(
        orderId: orderId,
        runnerId: runnerId,
        distanceToRestaurant: distanceToRestaurant,
        distanceToCustomer: distanceToCustomer,
        commission: commission,
      );
      final updatedOrder = await _orderRepository.fetchOrder(orderId);
      _currentOrder = updatedOrder;
      if (updatedOrder != null) {
        _listenToOrder(orderId);

        _notificationService.notifyCustomer(
          customerId: updatedOrder.customerId,
          title: 'Runner Assigned',
          body: 'A runner is heading to pick up your order!',
          data: {'type': 'order_status_update', 'orderId': orderId},
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderRepository.cancelOrder(orderId);
      _orderSubscription?.cancel();
      _orderSubscription = null;
      _currentOrder = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomerOrders(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderRepository.fetchCustomerOrders(customerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void streamCustomerOrders(String customerId) {
    _ordersSubscription?.cancel();
    _ordersSubscription =
        _orderRepository.streamCustomerOrders(customerId).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  void streamRestaurantOrders(String restaurantId) {
    _ordersSubscription?.cancel();
    _ordersSubscription =
        _orderRepository.streamRestaurantOrders(restaurantId).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  void streamAvailableOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription =
        _orderRepository.streamAvailableOrders().listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  void clearCurrentOrder() {
    _orderSubscription?.cancel();
    _orderSubscription = null;
    _currentOrder = null;
    notifyListeners();
  }

  void clearOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _orders = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _listenToOrder(String orderId) {
    _orderSubscription?.cancel();
    _orderSubscription =
        _orderRepository.streamOrder(orderId).listen((order) {
      _currentOrder = order;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
