import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/menu_item.dart';
import '../../mock_data/mock_route.dart';
import '../../models/order.dart';
import '../../theme/app_colors.dart';
import 'restaurant_discovery_screen.dart';

class OrderStatusScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<MenuItem> menuItems;

  const OrderStatusScreen({
    super.key,
    required this.cart,
    required this.menuItems,
  });

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  int _statusIndex = 0;
  Timer? _statusTimer;
  Timer? _runnerTimer;
  int _runnerWaypointIndex = 0;
  GoogleMapController? _mapController;

  OrderStatus get _currentStatus => OrderStatus.values[_statusIndex];

  @override
  void initState() {
    super.initState();
    _statusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _advanceStatus(),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _runnerTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _advanceStatus() {
    if (_statusIndex >= OrderStatus.values.length - 1) {
      _statusTimer?.cancel();
      return;
    }

    setState(() {
      _statusIndex++;
    });

    if (_currentStatus == OrderStatus.headedToYou) {
      _startRunnerSimulation();
    } else if (_currentStatus == OrderStatus.arrived) {
      _runnerTimer?.cancel();
      _runnerWaypointIndex = mockRunnerRoute.length - 1;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(mockCustomerLocation),
      );
    }
  }

  void _startRunnerSimulation() {
    _runnerWaypointIndex = 0;
    final interval = 5000 ~/ mockRunnerRoute.length;
    _runnerTimer = Timer.periodic(
      Duration(milliseconds: interval),
      (_) => _moveRunner(),
    );
  }

  void _moveRunner() {
    if (_runnerWaypointIndex >= mockRunnerRoute.length - 1) {
      _runnerTimer?.cancel();
      return;
    }

    if (!mounted) return;

    setState(() {
      _runnerWaypointIndex++;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(mockRunnerRoute[_runnerWaypointIndex]),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('restaurant'),
        position: mockRestaurantLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Restaurant'),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: mockCustomerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Delivery Location'),
      ),
    };

    if (_currentStatus == OrderStatus.headedToYou ||
        _currentStatus == OrderStatus.arrived) {
      markers.add(
        Marker(
          markerId: const MarkerId('runner'),
          position: mockRunnerRoute[_runnerWaypointIndex],
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Runner'),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (_currentStatus != OrderStatus.headedToYou &&
        _currentStatus != OrderStatus.arrived) {
      return {};
    }

    return {
      const Polyline(
        polylineId: PolylineId('route'),
        points: mockRunnerRoute,
        color: AppColors.primary,
        width: 4,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Status'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            _OrderStatusStepper(currentStatus: _currentStatus),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: GoogleMap(
                onMapCreated: (controller) => _mapController = controller,
                initialCameraPosition: const CameraPosition(
                  target: mockCustomerLocation,
                  zoom: 14.0,
                ),
                markers: _buildMarkers(),
                polylines: _buildPolylines(),
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _OrderReceiptSection(
              cart: widget.cart,
              menuItems: widget.menuItems,
            ),
          ],
        ),
        floatingActionButton: _currentStatus == OrderStatus.arrived
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestaurantDiscoveryScreen(),
                    ),
                    (route) => false,
                  );
                },
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                icon: const Icon(Icons.check),
                label: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _OrderStatusStepper extends StatelessWidget {
  final OrderStatus currentStatus;

  const _OrderStatusStepper({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final statuses = OrderStatus.values;
    final currentIndex = currentStatus.index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          for (int i = 0; i < statuses.length; i++) ...[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= currentIndex
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      border: i > currentIndex
                          ? Border.all(color: AppColors.silver, width: 2)
                          : null,
                    ),
                    child: Icon(
                      i < currentIndex ? Icons.check : statuses[i].icon,
                      size: 18,
                      color: i <= currentIndex
                          ? AppColors.onPrimary
                          : AppColors.silver,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statuses[i].label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: i <= currentIndex
                              ? AppColors.primary
                              : AppColors.blueSlate,
                          fontWeight: i == currentIndex
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
            if (i < statuses.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: i < currentIndex
                      ? AppColors.primary
                      : AppColors.silverLight,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _OrderReceiptSection extends StatelessWidget {
  final Map<String, int> cart;
  final List<MenuItem> menuItems;

  const _OrderReceiptSection({
    required this.cart,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    final cartItems =
        menuItems.where((item) => (cart[item.id] ?? 0) > 0).toList();
    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.price * (cart[item.id] ?? 0),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        children: [
          Text(
            'Receipt',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          ...cartItems.map((item) {
            final qty = cart[item.id]!;
            final lineTotal = item.price * qty;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.name}  x$qty',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                    ),
                  ),
                  Text(
                    '\$${lineTotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
