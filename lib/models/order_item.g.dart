// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  menuItemId: json['menuItemId'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'menuItemId': instance.menuItemId,
  'name': instance.name,
  'quantity': instance.quantity,
  'price': instance.price,
};
