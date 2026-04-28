import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../mock_data/mock_restaurants.dart';

class RestaurantDiscoveryScreen extends StatelessWidget {
  const RestaurantDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.tune),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                _FilterChipItem(label: '\$'),
                _FilterChipItem(label: '\$\$'),
                _FilterChipItem(label: '\$\$\$'),
                _FilterChipItem(label: 'Italian'),
                _FilterChipItem(label: 'Mexican'),
                _FilterChipItem(label: 'Japanese'),
                _FilterChipItem(label: 'Indian'),
                _FilterChipItem(label: 'American'),
                _FilterChipItem(label: 'Thai'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mockRestaurants.length,
              itemBuilder: (context, index) {
                return _RestaurantCard(restaurant: mockRestaurants[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;

  const _FilterChipItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: false,
        onSelected: (_) {},
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.silver.withAlpha(128)),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final MockRestaurant restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            color: AppColors.surfaceVariant,
            child: const Center(
              child: Icon(Icons.image, size: 48, color: AppColors.silver),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
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
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                const SizedBox(height: 6),
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
                const SizedBox(height: 6),
                Text(
                  restaurant.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.blueSlate,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
