// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) => Restaurant(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  cuisine: json['cuisine'] as String,
  priceLevel: (json['priceLevel'] as num).toInt(),
  rating: (json['rating'] as num).toDouble(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$RestaurantToJson(Restaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'name': instance.name,
      'description': instance.description,
      'cuisine': instance.cuisine,
      'priceLevel': instance.priceLevel,
      'rating': instance.rating,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
