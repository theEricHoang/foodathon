import 'package:flutter/material.dart';
import '../../mock_data/mock_orders.dart';
import '../../models/order.dart';
import '../../theme/app_colors.dart';

class RestaurantDashboardScreen extends StatelessWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(mockRestaurantName)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockRestaurantOrders.length,
        itemBuilder: (context, index) {
          final order = mockRestaurantOrders[index];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final MockOrder order;

  const _OrderCard({required this.order});

  Color get _statusBarColor => switch (order.status) {
        OrderStatus.sent => AppColors.error,
        OrderStatus.confirmed => Colors.amber,
        OrderStatus.readyForPickup => Colors.green,
        _ => AppColors.silver,
      };

  String? get _buttonLabel => switch (order.status) {
        OrderStatus.sent => 'Confirm',
        OrderStatus.confirmed => 'Mark Ready',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            color: _statusBarColor,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${item.quantity}x ${item.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.blueSlate,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                    ),
                    if (_buttonLabel != null)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 40),
                        ),
                        child: Text(_buttonLabel!),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
