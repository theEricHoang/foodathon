import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../mock_data/mock_menu_items.dart';

class CheckoutScreen extends StatelessWidget {
  final Map<String, int> cart;
  final List<MockMenuItem> menuItems;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    final cartItems =
        menuItems.where((item) => (cart[item.id] ?? 0) > 0).toList();
    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.price * (cart[item.id] ?? 0),
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
                quantity: cart[item.id]!,
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order confirmed!')),
          );
          Navigator.pop(context);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.check),
        label: const Text(
          'Confirm Order',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final MockMenuItem item;
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
