import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/auth/login_screen.dart';
import '../screens/customer/restaurant_discovery_screen.dart';
import '../screens/runner/runner_dashboard_screen.dart';

Widget homeScreenForRole(UserRole role) {
  switch (role) {
    case UserRole.customer:
      return const RestaurantDiscoveryScreen();
    case UserRole.runner:
      return const RunnerDashboardScreen();
    case UserRole.shopowner:
      return const LoginScreen();
  }
}
