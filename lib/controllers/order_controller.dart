import 'dart:convert';

import 'package:grocery_vendor_app/global_variable.dart';
import 'package:grocery_vendor_app/models/order.dart';
import 'package:grocery_vendor_app/services/manage_http_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderController {
  Future<List<Order>> loadOrders({required String vendorId}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      // Send an HTTP GET request to get the orders by the buyerID
      http.Response response = await http.get(
        Uri.parse("$uri/api/orders/vendors/$vendorId"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        // Parse the Json response body into dynamic List
        // This convert the json data into a formate that can be further processed in Dart.
        List<dynamic> data = jsonDecode(response.body);

        // Map the dynamic list to list of Orders object using the fromJson factory method
        // This step coverts the raw data into list of the orders instances, which are easier to work with.
        List<Order> orders =
            data.map((order) => Order.fromJson(order)).toList();
        return orders;
      } else {
        throw Exception("failed to load order ");
      }
    } catch (e) {
      // Handle any errors that occur during the order retrieval process
      // TODO: Implement error handling
      throw Exception("error loading Orders: $e");
    }
  }

  Future<void> deleteOrder({required String id, required context}) async {
    try {
      //send an HTTP Delete request to delete the order by _id
      http.Response response = await http.delete(
        Uri.parse("$uri/api/orders/$id"),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      //handle the HTTP Response
      manageHtppResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order Deleted successfully');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateDeliveryStatus(
      {required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/delivered'),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8"
        },
        body: jsonEncode({
          "delivered": true,
          "processing": false,
        }),
      );

      manageHtppResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order Updated');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> cancelOrder({required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/processing'),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8"
        },
        body: jsonEncode({
          "processing": false,
          "delivered": true,
        }),
      );

      manageHtppResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order Cancle');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
