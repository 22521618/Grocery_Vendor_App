import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_vendor_app/controllers/order_controller.dart';
import 'package:grocery_vendor_app/provider/order_provider.dart';
import 'package:grocery_vendor_app/provider/total_enrning_provider.dart';
import 'package:grocery_vendor_app/provider/vendor_provider.dart';

class EarningScreen extends ConsumerStatefulWidget {
  const EarningScreen({super.key});

  @override
  ConsumerState<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends ConsumerState<EarningScreen> {
  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = ref.read(vendorProvider);

    if (user != null) {
      final OrderController orderController = OrderController();

      try {
        final orders = await orderController.loadOrders(vendorId: user.id);

        ref.read(orderProvider.notifier).setOrders(orders);
        ref.read(totalEarningsProvider.notifier).calculateEarnings(orders);
        print(orders);
      } catch (e) {
        print('Error fetching order: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorProvider);
    final totalEarnings = ref.watch(totalEarningsProvider);
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text(
                  vendor!.fullName[0].toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ), // Text
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 200,
                child: Text(
                  "Hi ${vendor.fullName}",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ), // Text
              ), // SizedBox // CircleAvatar
            ],
          ), // Row
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Total Orders",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ), // Text
                const SizedBox(height: 8),
                Text(
                  '${totalEarnings['totalOrders']}',
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Total Earnings",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ), // Text
                const SizedBox(height: 8),
                Text(
                  '\$${totalEarnings['totalEarnings'].toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ), // Text
              ],
            ), // Column
          ),
        ) // AppBar
        ); // dot proper use cont
  }
}
