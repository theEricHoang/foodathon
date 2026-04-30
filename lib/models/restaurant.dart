import 'package:json_annotation/json_annotation.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class Restaurant {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String cuisine;
  final int priceLevel;
  final double rating;

  const Restaurant({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.cuisine,
    required this.priceLevel,
    required this.rating,
  });

  String get priceLevelLabel => '\$' * priceLevel;

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantToJson(this);
}
