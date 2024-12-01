import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_vendor_app/models/order.dart';

class OrderProvider extends StateNotifier<List<Order>> {
  OrderProvider() : super([]);

  void setOrders(List<Order> oders) {
    state = oders;
  }

  void updateOrderStatus(String orderId, {bool? processing, bool? delivered}) {
    // Update the state of the provider with a new list of orders
    state = [
      // Iterate through the existing orders
      for (final order in state)
        // Check if the current order's ID matches the ID we want to update
        if (order.id == orderId)
          Order(
            id: order.id,
            fullName: order.fullName,
            email: order.email,
            state: order.state,
            city: order.city,
            locality: order.locality,
            productName: order.productName,
            productPrice: order.productPrice,
            quantity: order.quantity,
            category: order.category,
            image: order.image,
            buyerId: order.buyerId,
            vendorId: order.vendorId,
            processing: processing ?? order.processing,
            delivered: delivered ?? order.delivered,
          )
        else
          order,
    ];
  }
}

final orderProvider = StateNotifierProvider<OrderProvider, List<Order>>((ref) {
  return OrderProvider();
});
