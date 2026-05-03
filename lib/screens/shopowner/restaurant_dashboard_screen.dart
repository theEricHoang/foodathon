import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../mock_data/mock_orders.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../theme/app_colors.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  late List<OrderStatus> _orderStatuses;

  @override
  void initState() {
    super.initState();
    _orderStatuses =
        mockRestaurantOrders.map((order) => order.status).toList();
  }

  Future<void> _onSignOut() async {
    context.read<RestaurantProvider>().clearCurrentRestaurant();

    await context.read<AuthProvider>().signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _advanceStatus(int index) {
    setState(() {
      _orderStatuses[index] = switch (_orderStatuses[index]) {
        OrderStatus.sent => OrderStatus.confirmed,
        OrderStatus.confirmed => OrderStatus.readyForPickup,
        _ => _orderStatuses[index],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(mockRestaurantName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onSignOut,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockRestaurantOrders.length,
        itemBuilder: (context, index) {
          final order = mockRestaurantOrders[index];
          final status = _orderStatuses[index];
          return _OrderCard(
            order: order,
            status: status,
            onAction: _buttonLabel(status) != null
                ? () => _advanceStatus(index)
                : null,
          );
        },
      ),
    );
  }

  static String? _buttonLabel(OrderStatus status) => switch (status) {
        OrderStatus.sent => 'Confirm',
        OrderStatus.confirmed => 'Mark Ready',
        _ => null,
      };
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final OrderStatus status;
  final VoidCallback? onAction;

  const _OrderCard({
    required this.order,
    required this.status,
    required this.onAction,
  });

  Color get _statusBarColor => switch (status) {
        OrderStatus.sent => AppColors.error,
        OrderStatus.confirmed => Colors.amber,
        OrderStatus.readyForPickup => Colors.green,
        _ => AppColors.silver,
      };

  String? get _buttonLabel => switch (status) {
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
                        onPressed: onAction,
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
