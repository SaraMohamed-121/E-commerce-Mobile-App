import 'package:flutter/material.dart';
import 'main.dart';
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
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  void addProduct(String name, String category, double price, int stock) {
    setState(() {
      products.add(Product(
        id: DateTime.now().toString(),
        name: name,
        category: category,
        price: price,
        stock: stock,
      ));
    });
  }

  void deleteProduct(String id) {
    setState(() {
      products.removeWhere((product) => product.id == id);
    });
  }

  void showProductDialog({Product? product}) {
    if (product != null) {
      _nameController.text = product.name;
      _categoryController.text = product.category;
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
    } else {
      _nameController.clear();
      _categoryController.clear();
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
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _stockController,
                  decoration: InputDecoration(labelText: 'Stock Quantity'),
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
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!categories.contains(_categoryController.text.trim())) {
                  showErrorDialog('Category does not exist.');
                } else {
                  if (product == null) {
                    addProduct(
                      _nameController.text.trim(),
                      _categoryController.text.trim(),
                      double.tryParse(_priceController.text) ?? 0.0,
                      int.tryParse(_stockController.text) ?? 0,
                    );
                  } else {
                    setState(() {
                      product.name = _nameController.text.trim();
                      product.category = _categoryController.text.trim();
                      product.price = double.tryParse(_priceController.text) ?? 0.0;
                      product.stock = int.tryParse(_stockController.text) ?? 0;
                    });
                  }
                  Navigator.of(context).pop();
                }
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
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void navigateToRatingPanel(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => rating_page(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Products')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Add New Product'),
            trailing: Icon(Icons.add),
            onTap: () => showProductDialog(),
          ),
          Divider(),
          ...products.map((product) {
            return ListTile(
              title: Text(product.name),
              subtitle: Text('Category: ${product.category}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => showProductDialog(product: product),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteProduct(product.id),
                  ),
                  IconButton(
                    icon: Icon(Icons.star),
                    onPressed: () => navigateToRatingPanel(product),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

