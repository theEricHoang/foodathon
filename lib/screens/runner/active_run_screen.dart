import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../mock_data/mock_orders.dart';
import '../../mock_data/mock_route.dart';
import '../../models/order.dart';
import '../../theme/app_colors.dart';

class ActiveRunScreen extends StatefulWidget {
  final MockOrder order;

  const ActiveRunScreen({super.key, required this.order});

  @override
  State<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends State<ActiveRunScreen> {
  late OrderStatus _currentStatus;
  Timer? _statusTimer;
  Timer? _runnerTimer;
  int _runnerWaypointIndex = 0;
  GoogleMapController? _mapController;

  bool get _isHeadingToRestaurant =>
      _currentStatus == OrderStatus.confirmed ||
      _currentStatus == OrderStatus.readyForPickup;

  List<LatLng> get _activeRoute =>
      _isHeadingToRestaurant ? mockRunnerToRestaurantRoute : mockRunnerRoute;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
    _startRunnerSimulation(mockRunnerToRestaurantRoute);
    _statusTimer = Timer(
      const Duration(seconds: 8),
      _advanceStatus,
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
    if (!mounted) return;
    setState(() {
      _currentStatus = OrderStatus.readyForPickup;
    });
    _runnerTimer?.cancel();
    _runnerWaypointIndex = mockRunnerToRestaurantRoute.length - 1;
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(mockRestaurantLocation),
    );
  }

  void _startRunnerSimulation(List<LatLng> route) {
    _runnerWaypointIndex = 0;
    final interval = 5000 ~/ route.length;
    _runnerTimer = Timer.periodic(
      Duration(milliseconds: interval),
      (_) => _moveRunner(),
    );
  }

  void _moveRunner() {
    final route = _activeRoute;
    if (_runnerWaypointIndex >= route.length - 1) {
      _runnerTimer?.cancel();
      return;
    }

    if (!mounted) return;

    setState(() {
      _runnerWaypointIndex++;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(route[_runnerWaypointIndex]),
    );
  }

  void _pickUpOrder() {
    setState(() {
      _currentStatus = OrderStatus.headedToYou;
    });
    _startRunnerSimulation(mockRunnerRoute);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: mockRestaurantLocation,
          northeast: mockCustomerLocation,
        ),
        50,
      ),
    );
  }

  void _deliverOrder() {
    Navigator.pop(context);
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    markers.add(
      Marker(
        markerId: const MarkerId('runner'),
        position: _activeRoute[_runnerWaypointIndex],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'You'),
      ),
    );

    if (_isHeadingToRestaurant) {
      markers.add(
        Marker(
          markerId: const MarkerId('restaurant'),
          position: mockRestaurantLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: widget.order.restaurantName),
        ),
      );
    } else {
      markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: mockCustomerLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: widget.order.customerName),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _activeRoute,
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
          title: const Text('Active Run'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            _RunnerStatusStepper(currentStatus: _currentStatus),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: GoogleMap(
                onMapCreated: (controller) => _mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: mockRunnerStartLocation,
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
            _OrderDetailSection(order: widget.order),
          ],
        ),
        floatingActionButton: _currentStatus == OrderStatus.readyForPickup
            ? FloatingActionButton.extended(
                onPressed: _pickUpOrder,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                icon: const Icon(Icons.check),
                label: const Text(
                  'Picked Up',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            : _currentStatus == OrderStatus.headedToYou
                ? FloatingActionButton.extended(
                    onPressed: _deliverOrder,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    icon: const Icon(Icons.check),
                    label: const Text(
                      'Delivered',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

const List<OrderStatus> _runnerStatuses = [
  OrderStatus.confirmed,
  OrderStatus.readyForPickup,
  OrderStatus.headedToYou,
];

class _RunnerStatusStepper extends StatelessWidget {
  final OrderStatus currentStatus;

  const _RunnerStatusStepper({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _runnerStatuses.indexOf(currentStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          for (int i = 0; i < _runnerStatuses.length; i++) ...[
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
                      i < currentIndex
                          ? Icons.check
                          : _runnerStatuses[i].icon,
                      size: 18,
                      color: i <= currentIndex
                          ? AppColors.onPrimary
                          : AppColors.silver,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _runnerStatuses[i].label,
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
            if (i < _runnerStatuses.length - 1)
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

class _OrderDetailSection extends StatelessWidget {
  final MockOrder order;

  const _OrderDetailSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.restaurantName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              Text(
                '\$${order.commission.toStringAsFixed(2)} commission',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Delivering to ${order.customerName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.blueSlate,
                ),
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) {
            final lineTotal = item.price * item.quantity;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.name}  x${item.quantity}',
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
                '\$${order.total.toStringAsFixed(2)}',
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
