import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../theme/app_colors.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadRestaurantAndOrders();
  }

  Future<void> _loadRestaurantAndOrders() async {
    final restaurantProvider = context.read<RestaurantProvider>();
    var restaurant = restaurantProvider.currentRestaurant;

    if (restaurant == null) {
      final user = context.read<UserProvider>().currentUser;
      if (user != null) {
        await restaurantProvider.fetchRestaurantByOwnerId(user.id);
        restaurant = restaurantProvider.currentRestaurant;
      }
    }

    if (restaurant != null && mounted) {
      context.read<OrderProvider>().streamRestaurantOrders(restaurant.id);
    }
  }

  Future<void> _onSignOut() async {
    context.read<OrderProvider>().clearOrders();
    context.read<RestaurantProvider>().clearCurrentRestaurant();

    await context.read<AuthProvider>().signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _advanceStatus(Order order) async {
    final nextStatus = switch (order.status) {
      OrderStatus.sent => OrderStatus.confirmed,
      OrderStatus.confirmed => OrderStatus.readyForPickup,
      _ => null,
    };

    if (nextStatus == null) return;

    await context.read<OrderProvider>().updateOrderStatus(
          orderId: order.id,
          status: nextStatus,
        );

    if (!mounted) return;

    final error = context.read<OrderProvider>().errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      context.read<OrderProvider>().clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantProvider>().currentRestaurant;
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant?.name ?? 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onSignOut,
          ),
        ],
      ),
      body: orderProvider.isLoading && orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(
                  child: Text('No orders yet.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _OrderCard(
                      order: order,
                      onAction: _buttonLabel(order.status) != null
                          ? () => _advanceStatus(order)
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
  final VoidCallback? onAction;

  const _OrderCard({
    required this.order,
    required this.onAction,
  });

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
