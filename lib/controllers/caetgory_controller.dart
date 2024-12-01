import 'dart:convert';

import 'package:grocery_vendor_app/global_variable.dart';
import 'package:grocery_vendor_app/models/category.dart';

import 'package:http/http.dart' as http;

class CategoryController {
  Future<List<Category>> loadCategories() async {
    try {
      // send an http get request to load the categories
      http.Response response = await http.get(
        Uri.parse('$uri/api/categories'),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8"
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<Category> categories =
            data.map((category) => Category.fromJson(category)).toList();
        return categories;
      } else {
        throw Exception("Failed to load categoryImage");
      }
    } catch (e) {
      throw Exception("Error to loading categories $e");
    }
  }
}
