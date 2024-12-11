import 'package:flutter/material.dart';

// Mock data for categories and products
List<Map<String, String>> categories = [
  {'name': 'Electronics', 'image': 'assets/electronics.jpg'},
  {'name': 'Accessories', 'image': 'assets/accessories.jpg'},
  {'name': 'Clothing', 'image': 'assets/clothing.jpg'},
  {'name': 'Books', 'image': 'assets/books.jpg'},
  {'name': 'Toys', 'image': 'assets/toys.jpg'},
];

List<Map<String, dynamic>> products = [
  {'name': 'Laptop', 'category': 'Electronics', 'price': 50000, 'image': 'assets/electronics1.jpg'},
  {'name': 'Smartphone', 'category': 'Electronics', 'price': 30000, 'image': 'assets/electronics2.jpg'},
  {'name': 'Headphones', 'category': 'Electronics', 'price': 5000, 'image': 'assets/electronics3.jpg'},
  {'name': 'Necklace & Bracelet', 'category': 'Accessories', 'price': 300, 'image': 'assets/accessories1.jpg'},
  {'name': 'Earrings', 'category': 'Accessories', 'price': 500, 'image': 'assets/accessories2.jpg'},
  {'name': 'Watches', 'category': 'Accessories', 'price': 700, 'image': 'assets/accessories3.jpg'},
  {'name': 'Full Set', 'category': 'Clothing', 'price': 5000, 'image': 'assets/clothing1.jpg'},
  {'name': 'Book', 'category': 'Books', 'price': 20, 'image': 'assets/books1.jpg'},
  {'name': 'Toy', 'category': 'Toys', 'price': 10, 'image': 'assets/toys1.jpg'},
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Shopping',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.pink[50],
        appBarTheme: AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: CategoryScreen(),
    );
  }
}

class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Shopping'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => CartScreen(),
              ));
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => ProductScreen(categories[index]['name']!),
              ));
            },
            child: Card(
              elevation: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      categories[index]['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      categories[index]['name']!,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductScreen extends StatefulWidget {
  final String category;

  ProductScreen(this.category);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> categoryProducts = [];

  @override
  void initState() {
    super.initState();
    categoryProducts = products.where((product) {
      return product['category'] == widget.category;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: categoryProducts.length,
        itemBuilder: (ctx, index) {
          return ListTile(
            leading: Image.asset(categoryProducts[index]['image']!, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(categoryProducts[index]['name']!),
            subtitle: Text('\$${categoryProducts[index]['price']}'),
            trailing: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                Cart.addToCart(categoryProducts[index]);
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: Cart.cartItems.length,
              itemBuilder: (ctx, index) {
                final item = Cart.cartItems[index];
                return ListTile(
                  leading: Image.asset(item['image']!, width: 50, height: 50),
                  title: Text(item['name']),
                  subtitle: Text('\$${item['price']} x ${item['quantity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          Cart.decreaseQuantity(item);
                          (context as Element).markNeedsBuild();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Cart.increaseQuantity(item);
                          (context as Element).markNeedsBuild();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          Cart.removeFromCart(item);
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Total: \$${Cart.calculateTotal()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Order Submitted'),
                  content: Text('Thank you for your order!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Cart.clearCart();
                        (context as Element).markNeedsBuild();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Checkout'),
          ),
        ],
      ),
    );
  }
}

class Cart {
  static List<Map<String, dynamic>> cartItems = [];

  static void addToCart(Map<String, dynamic> product) {
    cartItems.add({
      'name': product['name'],
      'price': product['price'],
      'image': product['image'],
      'quantity': 1,
    });
  }

  static void removeFromCart(Map<String, dynamic> product) {
    cartItems.remove(product);
  }

  static void increaseQuantity(Map<String, dynamic> product) {
    product['quantity'] += 1;
  }

  static void decreaseQuantity(Map<String, dynamic> product) {
    if (product['quantity'] > 1) {
      product['quantity'] -= 1;
    }
  }

  static int calculateTotal() {
  return cartItems.fold(
    0,
    (total, item) => (total + (item['price'] ?? 0) * (item['quantity'] ?? 0)).toInt(),
  );
}


  static void clearCart() {
    cartItems.clear();
  }
}
