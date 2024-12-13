import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rating_page.dart';
class Product {
  final String id;
  String name;
  String category;
  double price;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num).toDouble(),
      stock: data['stock'] ?? 0,
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String? _selectedCategory;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchCategories() async {
    try {
      final snapshot = await firestore.collection('Category').get();
      return snapshot.docs.map((doc) => doc['name'].toString()).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<Product>> fetchProducts() async {
    try {
      final snapshot = await firestore.collection('Product').get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<void> addProduct(String name, String category, double price, int stock) async {
    try {
      await firestore.collection('Product').add({
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'image': 'https://cdn-icons-png.flaticon.com/128/18543/18543297.png',
      });
    } catch (e) {
      showErrorDialog('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await firestore.collection('Product').doc(product.id).update({
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'stock': product.stock,
        'image': 'assets/product.avif',
      });
    } catch (e) {
      showErrorDialog('Failed to update product: $e');
    }
  }

  void deleteProduct(String id) async {
    try {
      await firestore.collection('Product').doc(id).delete();
    } catch (e) {
      showErrorDialog('Failed to delete product: $e');
    }
  }

  void showProductDialog({Product? product, required List<String> categories}) {
    if (product != null) {
      _nameController.text = product.name;
      _selectedCategory = product.category;
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
    } else {
      _nameController.clear();
      _selectedCategory = null;
      _priceController.clear();
      _stockController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedCategory == null) {
                  showErrorDialog('Please select a category.');
                  return;
                }

                if (product == null) {
                  await addProduct(
                    _nameController.text.trim(),
                    _selectedCategory!,
                    double.tryParse(_priceController.text) ?? 0.0,
                    int.tryParse(_stockController.text) ?? 0,
                  );
                } else {
                  product.name = _nameController.text.trim();
                  product.category = _selectedCategory!;
                  product.price = double.tryParse(_priceController.text) ?? 0.0;
                  product.stock = int.tryParse(_stockController.text) ?? 0;
                  await updateProduct(product);
                }

                Navigator.of(context).pop();
              },
              child: Text(product == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      body: FutureBuilder<List<String>>(
        future: fetchCategories(),
        builder: (context, categorySnapshot) {
          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (categorySnapshot.hasError) {
            return Center(child: Text('Error: ${categorySnapshot.error}'));
          } else if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found.'));
          } else {
            final categories = categorySnapshot.data!;
            return FutureBuilder<List<Product>>(
              future: fetchProducts(),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (productSnapshot.hasError) {
                  return Center(child: Text('Error: ${productSnapshot.error}'));
                } else if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found.'));
                } else {
                  final products = productSnapshot.data!;
                  return ListView(
                    children: [
                      ListTile(
                        title: const Text('Add New Product'),
                        trailing: const Icon(Icons.add),
                        onTap: () => showProductDialog(categories: categories),
                      ),
                      const Divider(),
                      ...products.map((product) => ListTile(
                            title: Text(product.name),
                            subtitle: Text('Category: ${product.category} | Price: \$${product.price} | Stock: ${product.stock}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                                                    onPressed: () => showProductDialog(product: product, categories: categories),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    bool confirmDelete = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text('Are you sure you want to delete this product?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },),
                                
                                    
                                    IconButton (  
                                    icon: const Icon(Icons.stars,color: Colors.yellow,),
                                     onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => RatingPage(productId: product.id)),
                                          );
                                          setState(() {});
                                        },
                                    ),
                                  
                              ],
                            ),
                          )),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}

