import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/runner_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../theme/app_colors.dart';
import '../../mock_data/mock_orders.dart';
import '../../models/order.dart';
import 'active_run_screen.dart';

class RunnerDashboardScreen extends StatefulWidget {
  const RunnerDashboardScreen({super.key});

  @override
  State<RunnerDashboardScreen> createState() => _RunnerDashboardScreenState();
}

class _RunnerDashboardScreenState extends State<RunnerDashboardScreen> {
  late List<Order> _availableOrders;

  @override
  void initState() {
    super.initState();
    _availableOrders = List.of(mockOrders);
    _loadRunnerProfile();
  }

  Future<void> _loadRunnerProfile() async {
    final userId = context.read<UserProvider>().currentUser!.id;
    final runnerProvider = context.read<RunnerProvider>();
    await runnerProvider.fetchRunnerByUserId(userId);
    if (runnerProvider.currentRunner == null && runnerProvider.errorMessage == null) {
      await runnerProvider.createRunner(userId: userId);
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

  void _acceptOrder(int index) {
    final order = _availableOrders[index];
    setState(() {
      _availableOrders.removeAt(index);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveRunScreen(order: order),
      ),
    );
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
            child: _availableOrders.isEmpty
                ? Center(
                    child: Text(
                      'No available orders',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.blueSlate,
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _availableOrders.length,
                    itemBuilder: (context, index) {
                      return _RunnerOrderCard(
                        order: _availableOrders[index],
                        onAccept: () => _acceptOrder(index),
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
  final VoidCallback onAccept;

  const _RunnerOrderCard({
    required this.order,
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
                  '${order.distanceToRestaurant ?? 0} mi to restaurant',
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
