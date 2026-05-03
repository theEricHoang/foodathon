import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../mock_data/mock_route.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';

class ActiveRunScreen extends StatefulWidget {
  final String orderId;

  const ActiveRunScreen({super.key, required this.orderId});

  @override
  State<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends State<ActiveRunScreen> {
  Timer? _runnerTimer;
  int _runnerWaypointIndex = 0;
  GoogleMapController? _mapController;
  OrderStatus? _lastKnownStatus;

  bool _isHeadingToRestaurant(OrderStatus status) =>
      status == OrderStatus.confirmed ||
      status == OrderStatus.readyForPickup;

  List<LatLng> _activeRoute(OrderStatus status) =>
      _isHeadingToRestaurant(status) ? mockRunnerToRestaurantRoute : mockRunnerRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrder(widget.orderId);
    });
    _startRunnerSimulation(mockRunnerToRestaurantRoute);
  }

  @override
  void dispose() {
    _runnerTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
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
    final orderProvider = context.read<OrderProvider>();
    final currentStatus = orderProvider.currentOrder?.status;
    final route = currentStatus != null
        ? _activeRoute(currentStatus)
        : mockRunnerToRestaurantRoute;

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

  Future<void> _pickUpOrder() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.updateOrderStatus(
      orderId: widget.orderId,
      status: OrderStatus.headedToYou,
    );
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

  Future<void> _deliverOrder() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.updateOrderStatus(
      orderId: widget.orderId,
      status: OrderStatus.arrived,
    );
    orderProvider.clearCurrentOrder();

    if (!mounted) return;
    Navigator.pop(context);
  }

  Set<Marker> _buildMarkers(OrderStatus status) {
    final markers = <Marker>{};
    final route = _activeRoute(status);

    markers.add(
      Marker(
        markerId: const MarkerId('runner'),
        position: route[_runnerWaypointIndex.clamp(0, route.length - 1)],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'You'),
      ),
    );

    final order = context.read<OrderProvider>().currentOrder;

    if (_isHeadingToRestaurant(status)) {
      markers.add(
        Marker(
          markerId: const MarkerId('restaurant'),
          position: mockRestaurantLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: order?.restaurantName ?? 'Restaurant'),
        ),
      );
    } else {
      markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: mockCustomerLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: order?.customerName ?? 'Customer'),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(OrderStatus status) {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _activeRoute(status),
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
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final order = orderProvider.currentOrder;
            if (order == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentStatus = order.status;

            if (_lastKnownStatus == OrderStatus.confirmed &&
                currentStatus == OrderStatus.readyForPickup) {
              _runnerTimer?.cancel();
              _runnerWaypointIndex = mockRunnerToRestaurantRoute.length - 1;
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(mockRestaurantLocation),
              );
            }
            _lastKnownStatus = currentStatus;

            return Column(
              children: [
                _RunnerStatusStepper(currentStatus: currentStatus),
                const Divider(height: 1, color: AppColors.divider),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: mockRunnerStartLocation,
                      zoom: 14.0,
                    ),
                    markers: _buildMarkers(currentStatus),
                    polylines: _buildPolylines(currentStatus),
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _OrderDetailSection(order: order),
              ],
            );
          },
        ),
        floatingActionButton: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final currentStatus = orderProvider.currentOrder?.status;
            if (currentStatus == OrderStatus.readyForPickup) {
              return FloatingActionButton.extended(
                onPressed: _pickUpOrder,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                icon: const Icon(Icons.check),
                label: const Text(
                  'Picked Up',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            } else if (currentStatus == OrderStatus.headedToYou) {
              return FloatingActionButton.extended(
                onPressed: _deliverOrder,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                icon: const Icon(Icons.check),
                label: const Text(
                  'Delivered',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
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
  final Order order;

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
                '\$${(order.commission ?? 0).toStringAsFixed(2)} commission',
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
