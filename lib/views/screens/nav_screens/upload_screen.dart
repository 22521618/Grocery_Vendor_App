import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_vendor_app/controllers/caetgory_controller.dart';
import 'package:grocery_vendor_app/controllers/product_controller.dart';
import 'package:grocery_vendor_app/controllers/subcategory_controller.dart';
import 'package:grocery_vendor_app/models/category.dart';
import 'package:grocery_vendor_app/models/subcategory.dart';
import 'package:grocery_vendor_app/provider/vendor_provider.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  late Future<List<Category>> futureCategories;
  Future<List<Subcategory>>? futureSubcategories;
  late String name;
  Category? selectedCategory;
  Subcategory? selectedSubcategory;

  late String productName;
  late double productPrice;
  late int quantity;
  late String description;

  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  final ImagePicker picker = ImagePicker();

  List<File> images = [];

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      print('No Image Picked');
    } else {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  getSubcategoryByCategory(value) {
    // fetch subcategories based on the selected category
    futureSubcategories =
        SubcategoryController().getSubCategoriesByCategoryName(value.name);
    selectedSubcategory = null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true, // Cho phép GridView co lại vừa với nội dung
              itemCount: images.length +
                  1, // Số lượng item trong lưới (+1 cho nút thêm)
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Số lượng cột trong mỗi hàng
                crossAxisSpacing: 4, // Khoảng cách giữa các cột
                mainAxisSpacing: 4, // Khoảng cách giữa các hàng
                childAspectRatio: 1, // Tỉ lệ chiều rộng/chiều cao của mỗi item
              ),
              itemBuilder: (context, index) {
                // Nếu index là 0, hiển thị một IconButton để thêm ảnh mới
                return index == 0
                    ? Center(
                        child: IconButton(
                            onPressed: () {
                              chooseImage();
                            },
                            icon: Icon(Icons.add)),
                      )
                    : SizedBox(
                        width: 50,
                        height: 40,
                        child: Image.file(images[index - 1]),
                      );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      onChanged: (value) {
                        productName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Name";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter product name',
                        hintText: 'Enter product name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        productPrice = double.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Price";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter product Price',
                        hintText: 'Enter product price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        quantity = int.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Quantity";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter product Quantity',
                        hintText: 'Enter product Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 200,
                    child: FutureBuilder<List<Category>>(
                      future: futureCategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          ); // Center
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text('No Category'),
                          ); // Center
                        } else {
                          return DropdownButton<Category>(
                            value: selectedCategory,
                            hint: const Text('Select Category'),
                            items: snapshot.data!.map((Category category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                              getSubcategoryByCategory(selectedCategory);
                              print(selectedCategory!.name);
                            },
                          );
                        }
                      },
                    ),
                  ), // FutureBuild
                  SizedBox(
                    width: 200,
                    child: FutureBuilder<List<Subcategory>>(
                      future: futureSubcategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          ); // Center
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text('No SubCategory'),
                          ); // Center
                        } else {
                          return DropdownButton<Subcategory>(
                            value: selectedSubcategory,
                            hint: const Text('Select SubCategory'),
                            items:
                                snapshot.data!.map((Subcategory subcategories) {
                              return DropdownMenuItem(
                                value: subcategories,
                                child: Text(subcategories.subCategoryName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSubcategory = value;
                              });
                              print(selectedSubcategory!.subCategoryName);
                            },
                          );
                        }
                      },
                    ),
                  ), // Futu
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      onChanged: (value) {
                        description = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Description";
                        } else {
                          return null;
                        }
                      },
                      maxLines: 3,
                      maxLength: 500,
                      decoration: InputDecoration(
                        labelText: 'Enter product Description',
                        hintText: 'Enter product Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: InkWell(
                onTap: () async {
                  final fullName = ref.read(vendorProvider)!.fullName;
                  final vendorId = ref.read(vendorProvider)!.id;
                  if (_formkey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    await _productController
                        .uploadProduct(
                      productName: productName,
                      productPrice: productPrice,
                      quantity: quantity,
                      description: description,
                      category: selectedCategory!.name,
                      vendorId: vendorId,
                      fullName: fullName,
                      subCategory: selectedSubcategory!.subCategoryName,
                      pickedImages: images,
                      context: context,
                    )
                        .whenComplete(() {
                      setState(() {
                        isLoading = false;
                      });
                      selectedCategory = null;
                      selectedSubcategory = null;
                      images.clear();
                    });
                  } else {
                    print("Please enter all the field");
                  }
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            'Upload Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.7,
                            ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
