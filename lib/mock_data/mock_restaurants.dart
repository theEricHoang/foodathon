class MockRestaurant {
  final String name;
  final String description;
  final String cuisine;
  final int priceLevel;
  final double rating;

  const MockRestaurant({
    required this.name,
    required this.description,
    required this.cuisine,
    required this.priceLevel,
    required this.rating,
  });

  String get priceLevelLabel => '\$' * priceLevel;
}

const List<MockRestaurant> mockRestaurants = [
  MockRestaurant(
    name: 'Bella Napoli',
    description: 'Authentic wood-fired pizzas and handmade pastas from family recipes passed down through generations.',
    cuisine: 'Italian',
    priceLevel: 2,
    rating: 4.7,
  ),
  MockRestaurant(
    name: 'El Camino Taqueria',
    description: 'Street-style tacos, fresh salsas, and slow-cooked meats served with handmade tortillas.',
    cuisine: 'Mexican',
    priceLevel: 1,
    rating: 4.5,
  ),
  MockRestaurant(
    name: 'Sakura House',
    description: 'Premium sushi and ramen crafted with imported ingredients and traditional Japanese techniques.',
    cuisine: 'Japanese',
    priceLevel: 3,
    rating: 4.8,
  ),
  MockRestaurant(
    name: 'Curry Kingdom',
    description: 'Rich curries, fluffy naan, and aromatic biryanis made with freshly ground spices.',
    cuisine: 'Indian',
    priceLevel: 2,
    rating: 4.4,
  ),
  MockRestaurant(
    name: 'Smokehouse BBQ',
    description: 'Low-and-slow smoked brisket, ribs, and pulled pork with signature house-made sauces.',
    cuisine: 'American',
    priceLevel: 2,
    rating: 4.6,
  ),
  MockRestaurant(
    name: 'Bangkok Bites',
    description: 'Vibrant Thai curries, stir-fries, and noodle dishes with bold and balanced flavors.',
    cuisine: 'Thai',
    priceLevel: 1,
    rating: 4.3,
  ),
];
