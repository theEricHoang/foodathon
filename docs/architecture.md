## Flutter Architecture (Provider-Based)

### high-level layers
- UI (screens/widgets)
- Providers (state + orchestration)
- Repositories (data abstraction)
- Services (Firebase SDK calls)

---

## Folder Structure

/lib

	/models
		user.dart
		restaurant.dart
		menu_item.dart
		order.dart
		runner.dart

	/services
		auth_service.dart
		firestore_service.dart
		storage_service.dart
		messaging_service.dart

	/repositories
		auth_repository.dart
		user_repository.dart
		restaurant_repository.dart
		order_repository.dart
		runner_repository.dart

	/providers
		auth_provider.dart
		user_provider.dart
		restaurant_provider.dart
		order_provider.dart
		runner_provider.dart

	/screens
		auth/
		customer/
		runner/
		shopowner/

---

## Core Principle

- **Services** → talk to Firebase
- **Repositories** → shape data for app
- **Providers** → hold state + expose to UI

---

## Auth Flow

### auth_provider.dart
- holds:
	- `FirebaseUser? user`
	- `bool isLoading`

- methods:
	- `signUp(email, password, username, role)`
	- `login(email, password)`
	- `logout()`

- behavior:
	- listens to Firebase Auth state changes
	- triggers loading of user profile

---

### user_provider.dart
- holds:
	- `UserModel? currentUser`
	- `bool isLoading`

- methods:
	- `fetchUser(uid)`
	- `updateUser(...)`

- used after auth to fetch Firestore user doc

---

## Restaurant State

### restaurant_provider.dart
- holds:
	- `List<Restaurant> restaurants`
	- `Restaurant? selectedRestaurant`
	- `List<MenuItem> menu`

- methods:
	- `fetchRestaurants()`
	- `listenToRestaurants()` (Firestore stream)
	- `fetchRestaurantDetail(id)`
	- `fetchMenu(restaurantId)`

- shopowner methods:
	- `createRestaurant()`
	- `addMenuItem()`

---

## Orders (CRITICAL REAL-TIME PIECE)

### order_provider.dart
- holds:
	- `List<Order> customerOrders`
	- `List<Order> activeOrders`
	- `Order? currentOrder`

- methods:
	- `createOrder(orderData)`
	- `cancelOrder(orderId)`
	- `listenToCustomerOrders(uid)`
	- `listenToRestaurantOrders(restaurantId)`
	- `listenToOrder(orderId)` ← core tracking

- behavior:
	- attaches Firestore listeners
	- updates UI automatically

---

## Runner State

### runner_provider.dart
- holds:
	- `bool isOnline`
	- `Order? assignedOrder`
	- `LatLng currentLocation`

- methods:
	- `goOnline() / goOffline()`
	- `updateLocation()`
	- `listenToAssignments(runnerId)`
	- `acceptOrder(orderId)`
	- `rejectOrder(orderId)`
	- `markPickedUp(orderId)`
	- `markDelivered(orderId)`

---

## Assignment Logic (IMPORTANT DESIGN NOTE)

⚠️ Do NOT run assignment logic in Flutter.

Instead:
- use Firestore listeners OR
- ideally use Firebase Cloud Functions

### recommended:
- Cloud Function triggers on:
	- order status → `ready`
- function:
	- queries available runners
	- computes score
	- writes assignment

Flutter should ONLY:
- listen to assignment results
- update UI

---

## Firestore Streams Pattern

Inside providers:

```dart
StreamSubscription? _ordersSub;

void listenToOrders(String uid) {
	_ordersSub?.cancel();

	_ordersSub = firestore
		.collection('orders')
		.where('customerId', isEqualTo: uid)
		.snapshots()
		.listen((snapshot) {
			customerOrders = snapshot.docs.map((d) => Order.fromDoc(d)).toList();
			notifyListeners();
		});
}
