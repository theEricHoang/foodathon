import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../models/order_item.dart';
import '../../models/restaurant.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import 'order_status_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<MenuItem> menuItems;
  final Restaurant restaurant;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.menuItems,
    required this.restaurant,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isSubmitting = false;

  Future<void> _confirmOrder() async {
    setState(() => _isSubmitting = true);

    final orderProvider = context.read<OrderProvider>();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser!;

    final cartItems = widget.menuItems
        .where((item) => (widget.cart[item.id] ?? 0) > 0)
        .toList();
    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.price * (widget.cart[item.id] ?? 0),
    );

    final items = cartItems.map((item) {
      return OrderItem(
        menuItemId: item.id,
        name: item.name,
        quantity: widget.cart[item.id]!,
        price: item.price,
      );
    }).toList();

    await orderProvider.createOrder(
      customerId: user.id,
      customerName: user.name,
      restaurantId: widget.restaurant.id,
      restaurantName: widget.restaurant.name,
      items: items,
      total: total,
    );

    if (!mounted) return;

    if (orderProvider.errorMessage != null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProvider.errorMessage!)),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OrderStatusScreen(orderId: orderProvider.currentOrder!.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.menuItems
        .where((item) => (widget.cart[item.id] ?? 0) > 0)
        .toList();
    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.price * (widget.cart[item.id] ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Your Order')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
          ),
          ...cartItems.map((item) => _CheckoutItemTile(
                item: item,
                quantity: widget.cart[item.id]!,
              )),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSubmitting ? null : _confirmOrder,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : const Icon(Icons.check),
        label: Text(
          _isSubmitting ? 'Placing Order...' : 'Confirm Order',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final MenuItem item;
  final int quantity;

  const _CheckoutItemTile({
    required this.item,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.price * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Qty: $quantity',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.blueSlate,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '\$${lineTotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
