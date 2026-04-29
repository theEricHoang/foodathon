import 'package:flutter/material.dart';

enum OrderStatus {
  sent,
  confirmed,
  readyForPickup,
  headedToYou,
  arrived;

  String get label {
    switch (this) {
      case OrderStatus.sent:
        return 'Sent';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.headedToYou:
        return 'Headed to You';
      case OrderStatus.arrived:
        return 'Arrived';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.sent:
        return Icons.send;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.readyForPickup:
        return Icons.store;
      case OrderStatus.headedToYou:
        return Icons.delivery_dining;
      case OrderStatus.arrived:
        return Icons.flag;
    }
  }
}
