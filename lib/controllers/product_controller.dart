import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:grocery_vendor_app/global_variable.dart';
import 'package:grocery_vendor_app/models/product.dart';
import 'package:grocery_vendor_app/services/manage_http_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductController {
  Future<void> uploadProduct({
    required String productName,
    required double productPrice,
    required int quantity,
    required String description,
    required String category,
    required String vendorId,
    required String fullName,
    required String subCategory,
    required List<File>? pickedImages,
    required context,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('auth_token');
    if (pickedImages != null) {
      final cloudinary = CloudinaryPublic("dwrchdx6d", 'rietpo2b');
      List<String> images = [];

      // Loop through each image in the pickedImages List
      for (var i = 0; i < pickedImages.length; i++) {
        // Await the upload of the current image to cloudinary
        CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedImages[i].path, folder: productName),
        );

        // Add the secure URL to the images list
        images.add(cloudinaryResponse.secureUrl);
      }
      if (category.isNotEmpty && subCategory.isNotEmpty) {
        final Product product = Product(
          id: '',
          productName: productName,
          productPrice: productPrice,
          quantity: quantity,
          description: description,
          category: category,
          vendorId: vendorId,
          fullName: fullName,
          subCategory: subCategory,
          images: images,
        );

        http.Response response = await http.post(
          Uri.parse("$uri/api/add-product"),
          body: product.toJson(),
          headers: <String, String>{
            "Content-Type": "application/json; charset=UTF-8",
            'x-auth-token': token!,
          },
        );
        manageHtppResponse(
            response: response,
            context: context,
            onSuccess: () {
              showSnackBar(context, "Product Uploaded");
            });
      } else {
        showSnackBar(context, "Select Category");
      }
    } else {
      showSnackBar(context, 'Selected Image');
    }
  }
}
