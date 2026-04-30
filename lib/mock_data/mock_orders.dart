import '../models/order.dart';

class MockOrderItem {
  final String name;
  final int quantity;
  final double price;

  const MockOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class MockOrder {
  final String id;
  final String restaurantName;
  final String customerName;
  final List<MockOrderItem> items;
  final OrderStatus status;
  final double distanceToRestaurant;
  final double distanceToCustomer;
  final double commission;
  final double total;

  const MockOrder({
    required this.id,
    required this.restaurantName,
    required this.customerName,
    required this.items,
    required this.status,
    required this.distanceToRestaurant,
    required this.distanceToCustomer,
    required this.commission,
    required this.total,
  });
}

const String mockRestaurantName = 'Bella Napoli';

const List<MockOrder> mockRestaurantOrders = [
  MockOrder(
    id: 'rest-order-1',
    restaurantName: mockRestaurantName,
    customerName: 'Alice Johnson',
    items: [
      MockOrderItem(name: 'Margherita Pizza', quantity: 1, price: 14.99),
      MockOrderItem(name: 'Tiramisu', quantity: 2, price: 7.99),
    ],
    status: OrderStatus.sent,
    distanceToRestaurant: 0.0,
    distanceToCustomer: 2.5,
    commission: 0.0,
    total: 30.97,
  ),
  MockOrder(
    id: 'rest-order-2',
    restaurantName: mockRestaurantName,
    customerName: 'Bob Smith',
    items: [
      MockOrderItem(name: 'Pepperoni Pizza', quantity: 1, price: 16.99),
      MockOrderItem(name: 'Garlic Bread', quantity: 1, price: 5.99),
    ],
    status: OrderStatus.sent,
    distanceToRestaurant: 0.0,
    distanceToCustomer: 1.7,
    commission: 0.0,
    total: 22.98,
  ),
  MockOrder(
    id: 'rest-order-3',
    restaurantName: mockRestaurantName,
    customerName: 'Carol Davis',
    items: [
      MockOrderItem(name: 'Lasagna', quantity: 1, price: 18.99),
    ],
    status: OrderStatus.confirmed,
    distanceToRestaurant: 0.0,
    distanceToCustomer: 3.0,
    commission: 0.0,
    total: 18.99,
  ),
  MockOrder(
    id: 'rest-order-4',
    restaurantName: mockRestaurantName,
    customerName: 'Dan Wilson',
    items: [
      MockOrderItem(name: 'Caprese Salad', quantity: 1, price: 12.99),
      MockOrderItem(name: 'Spaghetti Carbonara', quantity: 1, price: 15.99),
      MockOrderItem(name: 'Tiramisu', quantity: 1, price: 7.99),
    ],
    status: OrderStatus.confirmed,
    distanceToRestaurant: 0.0,
    distanceToCustomer: 1.3,
    commission: 0.0,
    total: 36.97,
  ),
  MockOrder(
    id: 'rest-order-5',
    restaurantName: mockRestaurantName,
    customerName: 'Eve Martinez',
    items: [
      MockOrderItem(name: 'Bruschetta', quantity: 2, price: 9.99),
    ],
    status: OrderStatus.readyForPickup,
    distanceToRestaurant: 0.0,
    distanceToCustomer: 2.2,
    commission: 0.0,
    total: 19.98,
  ),
];

const List<MockOrder> mockOrders = [
  MockOrder(
    id: 'order-1',
    restaurantName: 'Bella Napoli',
    customerName: 'Alice Johnson',
    items: [
      MockOrderItem(name: 'Margherita Pizza', quantity: 1, price: 14.99),
      MockOrderItem(name: 'Tiramisu', quantity: 2, price: 7.99),
    ],
    status: OrderStatus.confirmed,
    distanceToRestaurant: 1.2,
    distanceToCustomer: 2.5,
    commission: 10.00,
    total: 30.97,
  ),
  MockOrder(
    id: 'order-2',
    restaurantName: 'El Camino Taqueria',
    customerName: 'Bob Smith',
    items: [
      MockOrderItem(name: 'Street Tacos', quantity: 3, price: 4.50),
      MockOrderItem(name: 'Churros', quantity: 1, price: 5.99),
    ],
    status: OrderStatus.confirmed,
    distanceToRestaurant: 0.8,
    distanceToCustomer: 1.7,
    commission: 10.00,
    total: 19.49,
  ),
  MockOrder(
    id: 'order-3',
    restaurantName: 'Sakura House',
    customerName: 'Carol Davis',
    items: [
      MockOrderItem(name: 'Dragon Roll', quantity: 2, price: 16.99),
      MockOrderItem(name: 'Miso Soup', quantity: 1, price: 4.50),
    ],
    status: OrderStatus.confirmed,
    distanceToRestaurant: 2.1,
    distanceToCustomer: 3.0,
    commission: 10.00,
    total: 38.48,
  ),
  MockOrder(
    id: 'order-4',
    restaurantName: 'Curry Kingdom',
    customerName: 'Dan Wilson',
    items: [
      MockOrderItem(name: 'Butter Chicken', quantity: 1, price: 15.99),
      MockOrderItem(name: 'Garlic Naan', quantity: 2, price: 3.99),
    ],
    status: OrderStatus.confirmed,
    distanceToRestaurant: 0.5,
    distanceToCustomer: 1.3,
    commission: 10.00,
    total: 23.97,
  ),
  MockOrder(
    id: 'order-5',
    restaurantName: 'Smokehouse BBQ',
    customerName: 'Eve Martinez',
    items: [
      MockOrderItem(name: 'Brisket Plate', quantity: 1, price: 18.99),
      MockOrderItem(name: 'Coleslaw', quantity: 1, price: 4.50),
    ],
    status: OrderStatus.confirmed,
    distanceToRestaurant: 1.8,
    distanceToCustomer: 2.2,
    commission: 10.00,
    total: 23.49,
  ),
  MockOrder(
    id: 'order-6',
    restaurantName: 'Bangkok Bites',
    customerName: 'Frank Lee',
    items: [
      MockOrderItem(name: 'Pad Thai', quantity: 2, price: 13.99),
      MockOrderItem(name: 'Spring Rolls', quantity: 1, price: 6.99),
    ],
    status: OrderStatus.confirmed,
    distanceToRestaurant: 0.3,
    distanceToCustomer: 1.9,
    commission: 10.00,
    total: 34.97,
  ),
];
