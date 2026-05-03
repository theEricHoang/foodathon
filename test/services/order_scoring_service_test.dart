import 'package:flutter_test/flutter_test.dart';
import 'package:foodathon/models/order.dart';
import 'package:foodathon/models/order_item.dart';
import 'package:foodathon/services/order_scoring_service.dart';

void main() {
  late OrderScoringService service;

  setUp(() {
    service = OrderScoringService();
  });

  Order _makeOrder({
    String id = '1',
    String restaurantId = 'r1',
    OrderStatus status = OrderStatus.confirmed,
    DateTime? createdAt,
  }) {
    return Order(
      id: id,
      customerId: 'c1',
      customerName: 'Customer',
      restaurantId: restaurantId,
      restaurantName: 'Restaurant',
      items: const [OrderItem(menuItemId: 'i1', name: 'Item', quantity: 1, price: 10)],
      status: status,
      total: 10.0,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  group('OrderScoringService', () {
    test('closer restaurant scores higher', () {
      final orders = [
        _makeOrder(id: 'far', restaurantId: 'rFar'),
        _makeOrder(id: 'near', restaurantId: 'rNear'),
      ];

      final locations = {
        'rNear': (lat: 34.0, lng: -118.0),
        'rFar': (lat: 34.08, lng: -118.0),
      };

      final scored = service.rankOrders(
        orders: orders,
        runnerLat: 34.0,
        runnerLng: -118.0,
        restaurantLocations: locations,
      );

      expect(scored.first.order.id, 'near');
      expect(scored.first.distanceMi!, lessThan(scored.last.distanceMi!));
    });

    test('older order scores higher than newer order', () {
      final orders = [
        _makeOrder(
          id: 'new',
          createdAt: DateTime.now(),
        ),
        _makeOrder(
          id: 'old',
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
      ];

      final locations = <String, ({double lat, double lng})>{
        'r1': (lat: 34.0, lng: -118.0),
      };

      final scored = service.rankOrders(
        orders: orders,
        runnerLat: 34.0,
        runnerLng: -118.0,
        restaurantLocations: locations,
      );

      expect(scored.first.order.id, 'old');
    });

    test('readyForPickup beats confirmed', () {
      final orders = [
        _makeOrder(id: 'confirmed', status: OrderStatus.confirmed),
        _makeOrder(id: 'ready', status: OrderStatus.readyForPickup),
      ];

      final locations = <String, ({double lat, double lng})>{
        'r1': (lat: 34.0, lng: -118.0),
      };

      final scored = service.rankOrders(
        orders: orders,
        runnerLat: 34.0,
        runnerLng: -118.0,
        restaurantLocations: locations,
      );

      expect(scored.first.order.id, 'ready');
    });

    test('missing restaurant coords handled gracefully', () {
      final orders = [
        _makeOrder(id: 'noCoords', restaurantId: 'unknown'),
        _makeOrder(id: 'hasCoords', restaurantId: 'rKnown'),
      ];

      final locations = <String, ({double lat, double lng})>{
        'rKnown': (lat: 34.0, lng: -118.0),
      };

      final scored = service.rankOrders(
        orders: orders,
        runnerLat: 34.0,
        runnerLng: -118.0,
        restaurantLocations: locations,
      );

      expect(scored.first.order.id, 'hasCoords');
      expect(scored.last.distanceMi, isNull);
    });

    test('scores are between 0 and 1', () {
      final orders = [
        _makeOrder(id: '1', restaurantId: 'r1'),
        _makeOrder(
          id: '2',
          restaurantId: 'r2',
          status: OrderStatus.readyForPickup,
          createdAt: DateTime.now().subtract(const Duration(minutes: 60)),
        ),
      ];

      final locations = <String, ({double lat, double lng})>{
        'r1': (lat: 34.0, lng: -118.0),
        'r2': (lat: 35.0, lng: -119.0),
      };

      final scored = service.rankOrders(
        orders: orders,
        runnerLat: 34.0,
        runnerLng: -118.0,
        restaurantLocations: locations,
      );

      for (final s in scored) {
        expect(s.score, greaterThanOrEqualTo(0.0));
        expect(s.score, lessThanOrEqualTo(1.0));
      }
    });
  });
}
