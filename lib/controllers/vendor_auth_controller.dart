import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_vendor_app/global_variable.dart';
import 'package:grocery_vendor_app/models/vendor.dart';
import 'package:grocery_vendor_app/provider/vendor_provider.dart';
import 'package:grocery_vendor_app/services/manage_http_response.dart';
import 'package:grocery_vendor_app/views/screens/main_vendor_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final providerContainer = ProviderContainer();

class VendorAuthController {
  Future<void> signUpVendor({
    required String fullName,
    required String email,
    required String password,
    required context,
  }) async {
    try {
      Vendor vendor = Vendor(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        localcity: '',
        role: '',
        password: password,
      );

      http.Response response = await http.post(
          Uri.parse("$uri/api/vendor/signup"),
          body: vendor
              .toJson(), //Covert the Vendor user object to json for the request body
          headers: <String, String>{
            //Set the Headers for the request
            "Content-Type": "application/json; charset=UTF-8",
          });

      manageHtppResponse(
          response: response,
          context: context,
          onSuccess: () {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return MainVendorScreen();
            }), (route) => false);
            showSnackBar(context, "vendor created ");
          });
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  Future<void> signInVendor({
    required String email,
    required String password,
    required context,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/vendor/signin'),
        body: jsonEncode({"email": email, "password": password}),
        headers: <String, String>{
          //Set the Headers for the request
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      manageHtppResponse(
        response: response,
        context: context,
        onSuccess: () async {
          print('sucess');
          SharedPreferences preferences = await SharedPreferences.getInstance();

          final String token = jsonDecode(response.body)['token'];
          if (token != null) {
            await preferences.setString('auth_token', token);
          } else {
            throw Exception('Token không tồn tại trong response.');
          }

          // Kiểm tra và lấy vendor
          final vendor = jsonDecode(response.body);
          if (vendor != null && vendor is Map<String, dynamic>) {
            final vendorJson = jsonEncode(vendor);
            providerContainer
                .read(vendorProvider.notifier)
                .setVendor(vendorJson);
            await preferences.setString('vendor', vendorJson);
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return MainVendorScreen();
            }), (route) => false);
            showSnackBar(context, 'Loggin succesfuly');
          } else {
            throw Exception('Vendor không hợp lệ hoặc không tồn tại.');
          }
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }
}
