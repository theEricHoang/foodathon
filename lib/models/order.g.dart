// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  customerId: json['customerId'] as String,
  customerName: json['customerName'] as String,
  restaurantId: json['restaurantId'] as String,
  restaurantName: json['restaurantName'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  total: (json['total'] as num).toDouble(),
  runnerId: json['runnerId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'restaurantId': instance.restaurantId,
  'restaurantName': instance.restaurantName,
  'items': instance.items,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'total': instance.total,
  'runnerId': instance.runnerId,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$OrderStatusEnumMap = {
  OrderStatus.sent: 'sent',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.readyForPickup: 'readyForPickup',
  OrderStatus.headedToYou: 'headedToYou',
  OrderStatus.arrived: 'arrived',
};
