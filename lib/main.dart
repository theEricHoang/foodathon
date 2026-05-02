import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodathon/services/storage_service.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/restaurant_provider.dart';
import 'repositories/order_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/restaurant_repository.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = AuthService();
  final firestoreService = FirestoreService();
  final storageService = StorageService();
  final userRepository = UserRepository(
    authService: authService,
    firestoreService: firestoreService,
  );
  final orderRepository = OrderRepository(
    firestoreService: firestoreService,
  );
  final restaurantRepository = RestaurantRepository(
    firestoreService: firestoreService,
    storageService: storageService
  );

  final userProvider = UserProvider(userRepository: userRepository);
  final authProvider = AuthProvider(
    userRepository: userRepository,
    userProvider: userProvider,
  );

  authProvider.checkAuthState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(userRepository: userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderRepository: orderRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RestaurantProvider(restaurantRepository: restaurantRepository)
        ),
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodathon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
