import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../theme/app_colors.dart';
import '../../models/restaurant.dart';
import 'restaurant_detail_screen.dart';

class RestaurantDiscoveryScreen extends StatefulWidget {
  const RestaurantDiscoveryScreen({super.key});

  @override
  State<RestaurantDiscoveryScreen> createState() =>
      _RestaurantDiscoveryScreenState();
}

class _RestaurantDiscoveryScreenState extends State<RestaurantDiscoveryScreen> {
  final _searchController = TextEditingController();
  final Set<int> _selectedPriceLevels = {};
  final Set<String> _selectedCuisines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().streamRestaurants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Restaurant> get _filteredRestaurants {
    final restaurants = context.read<RestaurantProvider>().restaurants;
    final query = _searchController.text.toLowerCase();

    return restaurants.where((r) {
      if (query.isNotEmpty &&
          !r.name.toLowerCase().contains(query) &&
          !r.cuisine.toLowerCase().contains(query)) {
        return false;
      }
      if (_selectedPriceLevels.isNotEmpty &&
          !_selectedPriceLevels.contains(r.priceLevel)) {
        return false;
      }
      if (_selectedCuisines.isNotEmpty &&
          !_selectedCuisines.contains(r.cuisine)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _onSignOut() async {
    context.read<RestaurantProvider>().clearRestaurants();
    await context.read<AuthProvider>().signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = context.watch<RestaurantProvider>();
    final restaurants = _filteredRestaurants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onSignOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
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
              children: [
                _FilterChipItem(
                  label: '\$',
                  selected: _selectedPriceLevels.contains(1),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _selectedPriceLevels.add(1)
                        : _selectedPriceLevels.remove(1);
                  }),
                ),
                _FilterChipItem(
                  label: '\$\$',
                  selected: _selectedPriceLevels.contains(2),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _selectedPriceLevels.add(2)
                        : _selectedPriceLevels.remove(2);
                  }),
                ),
                _FilterChipItem(
                  label: '\$\$\$',
                  selected: _selectedPriceLevels.contains(3),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _selectedPriceLevels.add(3)
                        : _selectedPriceLevels.remove(3);
                  }),
                ),
                for (final cuisine in const [
                  'Italian',
                  'Mexican',
                  'Japanese',
                  'Indian',
                  'American',
                  'Thai',
                ])
                  _FilterChipItem(
                    label: cuisine,
                    selected: _selectedCuisines.contains(cuisine),
                    onSelected: (selected) => setState(() {
                      selected
                          ? _selectedCuisines.add(cuisine)
                          : _selectedCuisines.remove(cuisine);
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: restaurantProvider.isLoading &&
                    restaurantProvider.restaurants.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : restaurants.isEmpty
                    ? const Center(child: Text('No restaurants found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: restaurants.length,
                        itemBuilder: (context, index) {
                          return _RestaurantCard(
                              restaurant: restaurants[index]);
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
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? AppColors.onPrimary : AppColors.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.silver.withAlpha(128)),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RestaurantDetailScreen(restaurant: restaurant),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
    ),
    );
  }
}
