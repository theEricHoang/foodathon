import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../mock_data/mock_menu_items.dart';
import '../../models/menu_item.dart';
import '../../models/restaurant.dart';
import 'checkout_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final Map<String, int> _cart = {};

  int get _totalItems => _cart.values.fold(0, (sum, qty) => sum + qty);

  void _addToCart(String itemId) {
    setState(() {
      _cart[itemId] = (_cart[itemId] ?? 0) + 1;
    });
  }

  void _removeFromCart(String itemId) {
    setState(() {
      final current = _cart[itemId] ?? 0;
      if (current <= 1) {
        _cart.remove(itemId);
      } else {
        _cart[itemId] = current - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = mockMenuItems[widget.restaurant.name] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.restaurant.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          _RestaurantHeader(restaurant: widget.restaurant),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Menu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
          ),
          if (menuItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No menu items available.'),
            )
          else
            ...menuItems.map(
              (item) => _MenuItemTile(
                item: item,
                quantity: _cart[item.id] ?? 0,
                onAdd: () => _addToCart(item.id),
                onRemove: () => _removeFromCart(item.id),
              ),
            ),
        ],
      ),
      floatingActionButton: _totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                final menuItems =
                    mockMenuItems[widget.restaurant.name] ?? [];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      cart: Map<String, int>.from(_cart),
                      menuItems: menuItems,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '$_totalItems ${_totalItems == 1 ? 'item' : 'items'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantHeader({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          color: AppColors.surfaceVariant,
          child: const Center(
            child: Icon(Icons.image, size: 48, color: AppColors.silver),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                    ),
                  ),
                  Text(
                    restaurant.priceLevelLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(
                      restaurant.cuisine,
                      style: const TextStyle(
                        color: AppColors.onSecondary,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: AppColors.secondary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.star, size: 16, color: AppColors.coralGlow),
                  const SizedBox(width: 2),
                  Text(
                    restaurant.rating.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                restaurant.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.blueSlate,
                    ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItemTile({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.blueSlate,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          quantity == 0
              ? _AddButton(onTap: onAdd)
              : _QuantitySelector(
                  quantity: quantity,
                  onAdd: onAdd,
                  onRemove: onRemove,
                ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const Icon(Icons.add, color: AppColors.onPrimary, size: 20),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantitySelector({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circleButton(Icons.remove, onRemove),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          _circleButton(Icons.add, onAdd),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}
