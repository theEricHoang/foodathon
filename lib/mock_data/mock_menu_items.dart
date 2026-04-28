class MockMenuItem {
  final String id;
  final String name;
  final String description;
  final double price;

  const MockMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });
}

const Map<String, List<MockMenuItem>> mockMenuItems = {
  'Bella Napoli': [
    MockMenuItem(
      id: 'bn-1',
      name: 'Margherita Pizza',
      description: 'San Marzano tomatoes, fresh mozzarella, basil, extra virgin olive oil.',
      price: 12.99,
    ),
    MockMenuItem(
      id: 'bn-2',
      name: 'Spaghetti Carbonara',
      description: 'Guanciale, pecorino romano, egg yolk, black pepper.',
      price: 14.99,
    ),
    MockMenuItem(
      id: 'bn-3',
      name: 'Bruschetta',
      description: 'Grilled bread topped with diced tomatoes, garlic, and fresh basil.',
      price: 8.49,
    ),
    MockMenuItem(
      id: 'bn-4',
      name: 'Tiramisu',
      description: 'Espresso-soaked ladyfingers layered with mascarpone cream and cocoa.',
      price: 9.99,
    ),
    MockMenuItem(
      id: 'bn-5',
      name: 'Risotto ai Funghi',
      description: 'Arborio rice with porcini mushrooms, parmesan, and white wine.',
      price: 16.49,
    ),
  ],
  'El Camino Taqueria': [
    MockMenuItem(
      id: 'ec-1',
      name: 'Carne Asada Tacos',
      description: 'Grilled steak, cilantro, onion, salsa verde on corn tortillas.',
      price: 10.99,
    ),
    MockMenuItem(
      id: 'ec-2',
      name: 'Chicken Burrito',
      description: 'Seasoned chicken, rice, beans, cheese, pico de gallo in a flour tortilla.',
      price: 11.49,
    ),
    MockMenuItem(
      id: 'ec-3',
      name: 'Guacamole & Chips',
      description: 'Fresh avocado, lime, jalapeño, cilantro with house-made tortilla chips.',
      price: 7.99,
    ),
    MockMenuItem(
      id: 'ec-4',
      name: 'Churros',
      description: 'Crispy fried dough rolled in cinnamon sugar with chocolate dipping sauce.',
      price: 6.49,
    ),
    MockMenuItem(
      id: 'ec-5',
      name: 'Elote',
      description: 'Grilled street corn with mayo, cotija cheese, chili powder, and lime.',
      price: 5.99,
    ),
  ],
  'Sakura House': [
    MockMenuItem(
      id: 'sh-1',
      name: 'Salmon Nigiri (4pc)',
      description: 'Fresh Atlantic salmon over seasoned sushi rice.',
      price: 14.99,
    ),
    MockMenuItem(
      id: 'sh-2',
      name: 'Tonkotsu Ramen',
      description: 'Rich pork bone broth, chashu, soft egg, nori, green onion.',
      price: 16.99,
    ),
    MockMenuItem(
      id: 'sh-3',
      name: 'Dragon Roll',
      description: 'Shrimp tempura, avocado, eel sauce, sesame seeds.',
      price: 15.49,
    ),
    MockMenuItem(
      id: 'sh-4',
      name: 'Edamame',
      description: 'Steamed soybeans with sea salt.',
      price: 5.99,
    ),
    MockMenuItem(
      id: 'sh-5',
      name: 'Matcha Mochi',
      description: 'Soft rice cake filled with matcha green tea ice cream.',
      price: 7.49,
    ),
  ],
  'Curry Kingdom': [
    MockMenuItem(
      id: 'ck-1',
      name: 'Butter Chicken',
      description: 'Tender chicken in creamy tomato sauce with fenugreek and spices.',
      price: 13.99,
    ),
    MockMenuItem(
      id: 'ck-2',
      name: 'Garlic Naan',
      description: 'Soft leavened bread brushed with garlic butter.',
      price: 3.99,
    ),
    MockMenuItem(
      id: 'ck-3',
      name: 'Lamb Biryani',
      description: 'Fragrant basmati rice layered with spiced lamb and saffron.',
      price: 16.99,
    ),
    MockMenuItem(
      id: 'ck-4',
      name: 'Samosa (2pc)',
      description: 'Crispy pastry filled with spiced potatoes and peas.',
      price: 5.99,
    ),
    MockMenuItem(
      id: 'ck-5',
      name: 'Mango Lassi',
      description: 'Chilled yogurt drink blended with Alphonso mango.',
      price: 4.49,
    ),
  ],
  'Smokehouse BBQ': [
    MockMenuItem(
      id: 'sb-1',
      name: 'Smoked Brisket Plate',
      description: 'Slow-smoked beef brisket with coleslaw and cornbread.',
      price: 18.99,
    ),
    MockMenuItem(
      id: 'sb-2',
      name: 'Baby Back Ribs',
      description: 'Fall-off-the-bone pork ribs glazed with tangy BBQ sauce.',
      price: 21.99,
    ),
    MockMenuItem(
      id: 'sb-3',
      name: 'Pulled Pork Sandwich',
      description: 'Slow-cooked pulled pork on a brioche bun with pickles.',
      price: 12.99,
    ),
    MockMenuItem(
      id: 'sb-4',
      name: 'Mac & Cheese',
      description: 'Creamy three-cheese blend baked with a breadcrumb topping.',
      price: 6.99,
    ),
    MockMenuItem(
      id: 'sb-5',
      name: 'Pecan Pie',
      description: 'Classic southern pecan pie with a buttery flaky crust.',
      price: 7.99,
    ),
  ],
  'Bangkok Bites': [
    MockMenuItem(
      id: 'bb-1',
      name: 'Pad Thai',
      description: 'Stir-fried rice noodles with shrimp, peanuts, bean sprouts, and lime.',
      price: 13.49,
    ),
    MockMenuItem(
      id: 'bb-2',
      name: 'Green Curry',
      description: 'Coconut milk curry with Thai basil, bamboo shoots, and chicken.',
      price: 14.49,
    ),
    MockMenuItem(
      id: 'bb-3',
      name: 'Tom Yum Soup',
      description: 'Hot and sour broth with shrimp, mushrooms, lemongrass, and galangal.',
      price: 9.99,
    ),
    MockMenuItem(
      id: 'bb-4',
      name: 'Mango Sticky Rice',
      description: 'Sweet coconut sticky rice topped with fresh mango slices.',
      price: 8.49,
    ),
    MockMenuItem(
      id: 'bb-5',
      name: 'Thai Iced Tea',
      description: 'Strong brewed Thai tea with sweetened condensed milk over ice.',
      price: 4.99,
    ),
  ],
};
