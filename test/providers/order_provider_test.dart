import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:foodathon/models/order.dart';
import 'package:foodathon/models/order_item.dart';
import 'package:foodathon/providers/order_provider.dart';
import 'package:foodathon/repositories/order_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([OrderRepository])
import 'order_provider_test.mocks.dart';

Order _testOrder({
  String id = 'order1',
  String customerId = 'customer1',
  String customerName = 'Test Customer',
  String restaurantId = 'restaurant1',
  String restaurantName = 'Test Restaurant',
  List<OrderItem> items = const [],
  OrderStatus status = OrderStatus.sent,
  double total = 25.0,
  String? runnerId,
}) {
  return Order(
    id: id,
    customerId: customerId,
    customerName: customerName,
    restaurantId: restaurantId,
    restaurantName: restaurantName,
    items: items,
    status: status,
    total: total,
    runnerId: runnerId,
    createdAt: DateTime(2026),
  );
}

void main() {
  late MockOrderRepository mockRepo;
  late OrderProvider provider;

  setUp(() {
    mockRepo = MockOrderRepository();
    when(mockRepo.streamOrder(any)).thenAnswer((_) => const Stream.empty());
    when(mockRepo.streamCustomerOrders(any))
        .thenAnswer((_) => const Stream.empty());
    when(mockRepo.streamRestaurantOrders(any))
        .thenAnswer((_) => const Stream.empty());
    provider = OrderProvider(orderRepository: mockRepo);
  });

  tearDown(() {
    provider.dispose();
  });

  test('initial state', () {
    expect(provider.currentOrder, isNull);
    expect(provider.orders, isEmpty);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  group('createOrder', () {
    test('success sets currentOrder and starts stream', () async {
      final order = _testOrder();
      when(mockRepo.createOrder(
        customerId: 'customer1',
        customerName: 'Test Customer',
        restaurantId: 'restaurant1',
        restaurantName: 'Test Restaurant',
        items: const [],
        total: 25.0,
      )).thenAnswer((_) async => order);

      await provider.createOrder(
        customerId: 'customer1',
        customerName: 'Test Customer',
        restaurantId: 'restaurant1',
        restaurantName: 'Test Restaurant',
        items: const [],
        total: 25.0,
      );

      expect(provider.currentOrder, equals(order));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      verify(mockRepo.streamOrder('order1')).called(1);
    });

    test('failure sets errorMessage', () async {
      when(mockRepo.createOrder(
        customerId: anyNamed('customerId'),
        customerName: anyNamed('customerName'),
        restaurantId: anyNamed('restaurantId'),
        restaurantName: anyNamed('restaurantName'),
        items: anyNamed('items'),
        total: anyNamed('total'),
      )).thenThrow(Exception('Create failed'));

      await provider.createOrder(
        customerId: 'customer1',
        customerName: 'Test Customer',
        restaurantId: 'restaurant1',
        restaurantName: 'Test Restaurant',
        items: const [],
        total: 25.0,
      );

      expect(provider.currentOrder, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Create failed'));
    });
  });

  group('fetchOrder', () {
    test('success sets currentOrder and starts stream', () async {
      final order = _testOrder();
      when(mockRepo.fetchOrder('order1')).thenAnswer((_) async => order);

      await provider.fetchOrder('order1');

      expect(provider.currentOrder, equals(order));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      verify(mockRepo.streamOrder('order1')).called(1);
    });

    test('failure sets errorMessage', () async {
      when(mockRepo.fetchOrder('order1')).thenThrow(Exception('Fetch failed'));

      await provider.fetchOrder('order1');

      expect(provider.currentOrder, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Fetch failed'));
    });

    test('returns null — no error, no stream started', () async {
      when(mockRepo.fetchOrder('order1')).thenAnswer((_) async => null);

      await provider.fetchOrder('order1');

      expect(provider.currentOrder, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      verifyNever(mockRepo.streamOrder(any));
    });
  });

  group('updateOrderStatus', () {
    test('success calls repo', () async {
      when(mockRepo.updateOrderStatus(
        orderId: 'order1',
        status: OrderStatus.confirmed,
      )).thenAnswer((_) async {});

      await provider.updateOrderStatus(
        orderId: 'order1',
        status: OrderStatus.confirmed,
      );

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      verify(mockRepo.updateOrderStatus(
        orderId: 'order1',
        status: OrderStatus.confirmed,
      )).called(1);
    });

    test('failure sets errorMessage', () async {
      when(mockRepo.updateOrderStatus(
        orderId: 'order1',
        status: OrderStatus.confirmed,
      )).thenThrow(Exception('Update failed'));

      await provider.updateOrderStatus(
        orderId: 'order1',
        status: OrderStatus.confirmed,
      );

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Update failed'));
    });
  });

  group('assignRunner', () {
    test('success sets currentOrder with runnerId and starts stream', () async {
      final updatedOrder = _testOrder(runnerId: 'runner1');
      when(mockRepo.assignRunner(
        orderId: 'order1',
        runnerId: 'runner1',
      )).thenAnswer((_) async {});
      when(mockRepo.fetchOrder('order1'))
          .thenAnswer((_) async => updatedOrder);

      await provider.assignRunner(orderId: 'order1', runnerId: 'runner1');

      expect(provider.currentOrder, equals(updatedOrder));
      expect(provider.currentOrder?.runnerId, equals('runner1'));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      verify(mockRepo.streamOrder('order1')).called(1);
    });

    test('failure sets errorMessage', () async {
      when(mockRepo.assignRunner(
        orderId: 'order1',
        runnerId: 'runner1',
      )).thenThrow(Exception('Assign failed'));

      await provider.assignRunner(orderId: 'order1', runnerId: 'runner1');

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Assign failed'));
    });
  });

  group('cancelOrder', () {
    test('success clears currentOrder', () async {
      final order = _testOrder();
      when(mockRepo.fetchOrder('order1')).thenAnswer((_) async => order);
      await provider.fetchOrder('order1');

      when(mockRepo.cancelOrder('order1')).thenAnswer((_) async {});
      await provider.cancelOrder('order1');

      expect(provider.currentOrder, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('failure sets errorMessage', () async {
      when(mockRepo.cancelOrder('order1'))
          .thenThrow(Exception('Cancel failed'));

      await provider.cancelOrder('order1');

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Cancel failed'));
    });
  });

  group('fetchCustomerOrders', () {
    test('success populates orders list', () async {
      final orderList = [_testOrder(id: 'o1'), _testOrder(id: 'o2')];
      when(mockRepo.fetchCustomerOrders('customer1'))
          .thenAnswer((_) async => orderList);

      await provider.fetchCustomerOrders('customer1');

      expect(provider.orders, equals(orderList));
      expect(provider.orders.length, equals(2));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('failure sets errorMessage and orders stays empty', () async {
      when(mockRepo.fetchCustomerOrders('customer1'))
          .thenThrow(Exception('Fetch failed'));

      await provider.fetchCustomerOrders('customer1');

      expect(provider.orders, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Fetch failed'));
    });
  });

  group('streamCustomerOrders', () {
    test('updates orders on emit', () async {
      final controller = StreamController<List<Order>>();
      when(mockRepo.streamCustomerOrders('customer1'))
          .thenAnswer((_) => controller.stream);

      provider.streamCustomerOrders('customer1');

      final orderList = [_testOrder(id: 'o1')];
      controller.add(orderList);
      await Future<void>.delayed(Duration.zero);

      expect(provider.orders, equals(orderList));

      await controller.close();
    });

    test('cancels previous subscription', () async {
      final controller1 = StreamController<List<Order>>();
      final controller2 = StreamController<List<Order>>();
      when(mockRepo.streamCustomerOrders('customer1'))
          .thenAnswer((_) => controller1.stream);
      when(mockRepo.streamCustomerOrders('customer2'))
          .thenAnswer((_) => controller2.stream);

      provider.streamCustomerOrders('customer1');
      provider.streamCustomerOrders('customer2');

      expect(controller1.hasListener, isFalse);

      await controller1.close();
      await controller2.close();
    });
  });

  group('streamRestaurantOrders', () {
    test('updates orders on emit', () async {
      final controller = StreamController<List<Order>>();
      when(mockRepo.streamRestaurantOrders('restaurant1'))
          .thenAnswer((_) => controller.stream);

      provider.streamRestaurantOrders('restaurant1');

      final orderList = [_testOrder(id: 'o1')];
      controller.add(orderList);
      await Future<void>.delayed(Duration.zero);

      expect(provider.orders, equals(orderList));

      await controller.close();
    });
  });

  test('clearCurrentOrder resets and stops stream', () async {
    final controller = StreamController<Order?>();
    when(mockRepo.streamOrder('order1')).thenAnswer((_) => controller.stream);
    when(mockRepo.fetchOrder('order1'))
        .thenAnswer((_) async => _testOrder());

    await provider.fetchOrder('order1');
    provider.clearCurrentOrder();

    expect(provider.currentOrder, isNull);
    expect(controller.hasListener, isFalse);

    await controller.close();
  });

  test('clearOrders resets list and stops stream', () async {
    final controller = StreamController<List<Order>>();
    when(mockRepo.streamCustomerOrders('customer1'))
        .thenAnswer((_) => controller.stream);

    provider.streamCustomerOrders('customer1');
    provider.clearOrders();

    expect(provider.orders, isEmpty);
    expect(controller.hasListener, isFalse);

    await controller.close();
  });

  test('clearError resets errorMessage', () async {
    when(mockRepo.fetchOrder('order1')).thenThrow(Exception('error'));
    await provider.fetchOrder('order1');
    expect(provider.errorMessage, isNotNull);

    provider.clearError();

    expect(provider.errorMessage, isNull);
  });

  test('single order stream updates currentOrder', () async {
    final controller = StreamController<Order?>();
    when(mockRepo.streamOrder('order1')).thenAnswer((_) => controller.stream);
    when(mockRepo.fetchOrder('order1'))
        .thenAnswer((_) async => _testOrder());

    await provider.fetchOrder('order1');

    final updatedOrder = _testOrder(status: OrderStatus.confirmed);
    controller.add(updatedOrder);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentOrder?.status, equals(OrderStatus.confirmed));

    await controller.close();
  });

  test('dispose cancels both subscriptions', () async {
    final orderController = StreamController<Order?>();
    final ordersController = StreamController<List<Order>>();
    when(mockRepo.streamOrder('order1'))
        .thenAnswer((_) => orderController.stream);
    when(mockRepo.fetchOrder('order1'))
        .thenAnswer((_) async => _testOrder());
    when(mockRepo.streamCustomerOrders('customer1'))
        .thenAnswer((_) => ordersController.stream);

    final localProvider = OrderProvider(orderRepository: mockRepo);
    await localProvider.fetchOrder('order1');
    localProvider.streamCustomerOrders('customer1');

    localProvider.dispose();

    expect(orderController.hasListener, isFalse);
    expect(ordersController.hasListener, isFalse);

    await orderController.close();
    await ordersController.close();
  });
}
