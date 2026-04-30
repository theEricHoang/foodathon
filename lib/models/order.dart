import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'order_item.dart';

part 'order.g.dart';

enum OrderStatus {
  @JsonValue('sent')
  sent,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('readyForPickup')
  readyForPickup,
  @JsonValue('headedToYou')
  headedToYou,
  @JsonValue('arrived')
  arrived;

  String get label => switch (this) {
        OrderStatus.sent => 'Sent',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.readyForPickup => 'Ready for Pickup',
        OrderStatus.headedToYou => 'Headed to You',
        OrderStatus.arrived => 'Arrived',
      };

  IconData get icon => switch (this) {
        OrderStatus.sent => Icons.send,
        OrderStatus.confirmed => Icons.check_circle,
        OrderStatus.readyForPickup => Icons.store,
        OrderStatus.headedToYou => Icons.delivery_dining,
        OrderStatus.arrived => Icons.flag,
      };
}

@JsonSerializable()
class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final OrderStatus status;
  final double total;
  final String? runnerId;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.status,
    required this.total,
    this.runnerId,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
