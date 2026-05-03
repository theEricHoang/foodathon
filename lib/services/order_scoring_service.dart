import '../models/order.dart';
import 'location_service.dart';

class ScoredOrder {
  final Order order;
  final double score;
  final double? distanceMi;

  const ScoredOrder({
    required this.order,
    required this.score,
    this.distanceMi,
  });
}

class OrderScoringService {
  static const _distanceWeight = 0.40;
  static const _urgencyWeight = 0.35;
  static const _statusWeight = 0.25;
  static const _maxDistanceMi = 10.0;
  static const _maxWaitMinutes = 30.0;

  List<ScoredOrder> rankOrders({
    required List<Order> orders,
    required double runnerLat,
    required double runnerLng,
    required Map<String, ({double lat, double lng})> restaurantLocations,
  }) {
    final scored = orders.map((order) {
      final location = restaurantLocations[order.restaurantId];

      double? distance;
      double distanceScore = 0.0;
      if (location != null) {
        distance = LocationService.distanceMi(
          runnerLat,
          runnerLng,
          location.lat,
          location.lng,
        );
        distanceScore = (1.0 - distance / _maxDistanceMi).clamp(0.0, 1.0);
      }

      final minutesWaiting =
          DateTime.now().difference(order.createdAt).inMinutes.toDouble();
      final urgencyScore = (minutesWaiting / _maxWaitMinutes).clamp(0.0, 1.0);

      final statusBonus =
          order.status == OrderStatus.readyForPickup ? 1.0 : 0.0;

      final score = (_distanceWeight * distanceScore) +
          (_urgencyWeight * urgencyScore) +
          (_statusWeight * statusBonus);

      return ScoredOrder(order: order, score: score, distanceMi: distance);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }
}
