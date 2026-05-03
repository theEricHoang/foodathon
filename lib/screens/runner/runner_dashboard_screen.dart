import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/runner_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../services/order_scoring_service.dart';
import '../../theme/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import 'active_run_screen.dart';

class RunnerDashboardScreen extends StatefulWidget {
  const RunnerDashboardScreen({super.key});

  @override
  State<RunnerDashboardScreen> createState() => _RunnerDashboardScreenState();
}

class _RunnerDashboardScreenState extends State<RunnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRunnerProfile();
      context.read<OrderProvider>().streamAvailableOrders();
      context.read<RestaurantProvider>().fetchRestaurants();
    });
  }

  Future<void> _loadRunnerProfile() async {
    final userId = context.read<UserProvider>().currentUser!.id;
    final runnerProvider = context.read<RunnerProvider>();
    await runnerProvider.fetchRunnerByUserId(userId);
    if (runnerProvider.currentRunner == null && runnerProvider.errorMessage == null) {
      await runnerProvider.createRunner(userId: userId);
    }
    if (runnerProvider.currentRunner != null) {
      await runnerProvider.goOnline();
    }
  }

  Future<void> _onSignOut() async {
    final runnerProvider = context.read<RunnerProvider>();
    if (runnerProvider.currentRunner?.isOnline == true) {
      await runnerProvider.goOffline();
    }
    runnerProvider.clearCurrentRunner();

    if (!mounted) return;

    await context.read<AuthProvider>().signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _acceptOrder(Order order, {double? distanceMi}) async {
    final runnerProvider = context.read<RunnerProvider>();
    final orderProvider = context.read<OrderProvider>();
    final runnerId = runnerProvider.currentRunner?.id;
    if (runnerId == null) return;

    try {
      await orderProvider.assignRunner(
        orderId: order.id,
        runnerId: runnerId,
        distanceToRestaurant: distanceMi,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveRunScreen(orderId: order.id),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order already taken by another runner')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Runner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onSignOut,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, _) => Text(
                'Hello, ${userProvider.currentUser?.name ?? 'Runner'}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
            ),
          ),
          Expanded(
            child: Consumer3<OrderProvider, RunnerProvider, RestaurantProvider>(
              builder: (context, orderProvider, runnerProvider, restaurantProvider, _) {
                final availableOrders = orderProvider.orders;
                if (availableOrders.isEmpty) {
                  return Center(
                    child: Text(
                      'No available orders',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.blueSlate,
                          ),
                    ),
                  );
                }

                final runner = runnerProvider.currentRunner;
                final hasLocation = runner?.latitude != null && runner?.longitude != null;

                if (hasLocation) {
                  final restaurantLocations = <String, ({double lat, double lng})>{};
                  for (final r in restaurantProvider.restaurants) {
                    if (r.latitude != null && r.longitude != null) {
                      restaurantLocations[r.id] = (lat: r.latitude!, lng: r.longitude!);
                    }
                  }

                  final scoredOrders = OrderScoringService().rankOrders(
                    orders: availableOrders,
                    runnerLat: runner!.latitude!,
                    runnerLng: runner.longitude!,
                    restaurantLocations: restaurantLocations,
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: scoredOrders.length,
                    itemBuilder: (context, index) {
                      final scored = scoredOrders[index];
                      return _RunnerOrderCard(
                        order: scored.order,
                        distanceMi: scored.distanceMi,
                        onAccept: () => _acceptOrder(scored.order, distanceMi: scored.distanceMi),
                      );
                    },
                  );
                }

                final sortedOrders = List<Order>.from(availableOrders)
                  ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedOrders.length,
                  itemBuilder: (context, index) {
                    final order = sortedOrders[index];
                    return _RunnerOrderCard(
                      order: order,
                      onAccept: () => _acceptOrder(order),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RunnerOrderCard extends StatelessWidget {
  final Order order;
  final double? distanceMi;
  final VoidCallback onAccept;

  const _RunnerOrderCard({
    required this.order,
    this.distanceMi,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.restaurantName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_walk, size: 18, color: AppColors.blueSlate),
                const SizedBox(width: 6),
                Text(
                  '${(distanceMi ?? order.distanceToRestaurant ?? 0).toStringAsFixed(1)} mi to restaurant',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.blueSlate,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.delivery_dining, size: 18, color: AppColors.blueSlate),
                const SizedBox(width: 6),
                Text(
                  '${order.distanceToCustomer ?? 0} mi to customer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.blueSlate,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${(order.commission ?? 0).toStringAsFixed(2)} commission',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 40),
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
