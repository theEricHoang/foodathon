import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../mock_data/mock_route.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';
import 'restaurant_discovery_screen.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderId;

  const OrderStatusScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      if (orderProvider.currentOrder?.id != widget.orderId) {
        orderProvider.fetchOrder(widget.orderId);
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers() {
    return {
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
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final order = orderProvider.currentOrder;

            if (order == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _OrderStatusStepper(currentStatus: order.status),
                const Divider(height: 1, color: AppColors.divider),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: const CameraPosition(
                      target: mockCustomerLocation,
                      zoom: 14.0,
                    ),
                    markers: _buildMarkers(),
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _OrderReceiptSection(order: order),
              ],
            );
          },
        ),
        floatingActionButton: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final order = orderProvider.currentOrder;
            if (order == null || order.status != OrderStatus.arrived) {
              return const SizedBox.shrink();
            }
            return FloatingActionButton.extended(
              onPressed: () {
                orderProvider.clearCurrentOrder();
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
            );
          },
        ),
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
  final Order order;

  const _OrderReceiptSection({required this.order});

  @override
  Widget build(BuildContext context) {
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
