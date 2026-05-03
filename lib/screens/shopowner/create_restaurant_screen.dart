import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../providers/restaurant_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import 'restaurant_dashboard_screen.dart';

const _cuisines = [
  'Italian',
  'Mexican',
  'Japanese',
  'Indian',
  'American',
  'Thai',
];

class CreateRestaurantScreen extends StatefulWidget {
  const CreateRestaurantScreen({super.key});

  @override
  State<CreateRestaurantScreen> createState() => _CreateRestaurantScreenState();
}

class _CreateRestaurantScreenState extends State<CreateRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  String _selectedCuisine = _cuisines.first;
  int _priceLevel = 1;
  File? _restaurantImage;
  final List<_MenuItemEntry> _menuItems = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final entry in _menuItems) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _restaurantImage = File(picked.path);
      });
    }
  }

  void _addMenuItem() {
    setState(() {
      _menuItems.add(_MenuItemEntry(id: const Uuid().v4()));
    });
  }

  void _removeMenuItem(String id) {
    setState(() {
      final index = _menuItems.indexWhere((e) => e.id == id);
      if (index != -1) {
        _menuItems[index].dispose();
        _menuItems.removeAt(index);
      }
    });
  }

  Future<void> _onSubmit() async {
    if (_menuItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one menu item')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final ownerId = context.read<UserProvider>().currentUser!.id;
    final restaurantProvider = context.read<RestaurantProvider>();

    await restaurantProvider.createRestaurant(
      ownerId: ownerId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      cuisine: _selectedCuisine,
      priceLevel: _priceLevel,
      image: _restaurantImage,
    );

    if (!mounted) return;

    if (restaurantProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(restaurantProvider.errorMessage!)),
      );
      return;
    }

    final restaurantId = restaurantProvider.currentRestaurant!.id;
    for (final entry in _menuItems) {
      await restaurantProvider.addMenuItem(
        restaurantId: restaurantId,
        name: entry.nameController.text.trim(),
        description: entry.descriptionController.text.trim(),
        price: double.tryParse(entry.priceController.text.trim()) ?? 0.0,
      );
    }

    if (!mounted) return;

    if (restaurantProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(restaurantProvider.errorMessage!)),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RestaurantDashboardScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Restaurant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImagePickerSection(
                image: _restaurantImage,
                onTap: _pickImage,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  prefixIcon: Icon(Icons.storefront),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Restaurant name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCuisine,
                decoration: const InputDecoration(
                  labelText: 'Cuisine Type',
                  prefixIcon: Icon(Icons.restaurant),
                ),
                items: _cuisines
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCuisine = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Price Level',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('\$')),
                  ButtonSegment(value: 2, label: Text('\$\$')),
                  ButtonSegment(value: 3, label: Text('\$\$\$')),
                ],
                selected: {_priceLevel},
                onSelectionChanged: (selected) {
                  setState(() => _priceLevel = selected.first);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Menu Items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addMenuItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_menuItems.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  child: Text(
                    'No menu items yet. Tap "Add Item" to get started.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.silver,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              for (var i = 0; i < _menuItems.length; i++)
                Padding(
                  key: ValueKey(_menuItems[i].id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MenuItemCard(
                    entry: _menuItems[i],
                    index: i,
                    onRemove: () => _removeMenuItem(_menuItems[i].id),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Create Restaurant'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemEntry {
  final String id;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;

  _MenuItemEntry({required this.id})
      : nameController = TextEditingController(),
        descriptionController = TextEditingController(),
        priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
  }
}

class _ImagePickerSection extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const _ImagePickerSection({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: image != null
            ? Image.file(image!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: AppColors.silver,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add restaurant photo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.blueSlate,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final _MenuItemEntry entry;
  final int index;
  final VoidCallback onRemove;

  const _MenuItemCard({
    required this.entry,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Item ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  iconSize: 20,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry.nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                prefixIcon: Icon(Icons.fastfood),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Item name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Item Description',
                prefixIcon: Icon(Icons.notes),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry.priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Price is required';
                }
                final price = double.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return 'Enter a valid price';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
