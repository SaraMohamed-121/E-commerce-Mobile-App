import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Mock data for categories and products
List<Map<String, String>> categories = [
  {'name': 'Electronics', 'image': 'assets/electronics.jpg'},
  {'name': 'Accessories', 'image': 'assets/accessories.jpg'},
  {'name': 'Clothing', 'image': 'assets/clothing.jpg'},
  {'name': 'Books', 'image': 'assets/books.jpg'},
  {'name': 'Toys', 'image': 'assets/toys.jpg'},
];

List<Map<String, dynamic>> products = [
  {
    'name': 'Laptop',
    'category': 'Electronics',
    'price': 50000,
    'image': 'assets/electronics1.jpg'
  },
  {
    'name': 'Smartphone',
    'category': 'Electronics',
    'price': 30000,
    'image': 'assets/electronics2.jpg'
  },
  {
    'name': 'Headphones',
    'category': 'Electronics',
    'price': 5000,
    'image': 'assets/electronics3.jpg'
  },
  {
    'name': 'Smartphone',
    'category': 'Electronics',
    'price': 100000,
    'image': 'assets/electronics4.jpg'
  },
  {
    'name': 'Necklace & Bracelet',
    'category': 'Accessories',
    'price': 300,
    'image': 'assets/accessories1.jpg'
  },
  {
    'name': 'Earrings',
    'category': 'Accessories',
    'price': 500,
    'image': 'assets/accessories2.jpg'
  },
  {
    'name': 'Watches',
    'category': 'Accessories',
    'price': 700,
    'image': 'assets/accessories3.jpg'
  },
  {
    'name': 'Watches',
    'category': 'Accessories',
    'price': 900,
    'image': 'assets/accessories4.jpg'
  },
  {
    'name': 'Full Set',
    'category': 'Clothing',
    'price': 5000,
    'image': 'assets/clothing1.jpg'
  },
  {
    'name': 'Full Set',
    'category': 'Clothing',
    'price': 1000,
    'image': 'assets/clothing2.jpg'
  },
  {
    'name': 'Full Set',
    'category': 'Clothing',
    'price': 8000,
    'image': 'assets/clothing3.jpg'
  },
  {
    'name': 'Full Set',
    'category': 'Clothing',
    'price': 8000,
    'image': 'assets/clothing4.jpg'
  },
  {
    'name': 'Book',
    'category': 'Books',
    'price': 20,
    'image': 'assets/books1.jpg'
  },
  {
    'name': 'Book',
    'category': 'Books',
    'price': 20,
    'image': 'assets/books2.jpg'
  },
  {
    'name': 'Love Story',
    'category': 'Books',
    'price': 20,
    'image': 'assets/books3.jpg'
  },
  {
    'name': 'Texts',
    'category': 'Books',
    'price': 20,
    'image': 'assets/books4.jpg'
  },
  {'name': 'Toy', 'category': 'Toys', 'price': 10, 'image': 'assets/toys1.jpg'},
  {'name': 'Toy', 'category': 'Toys', 'price': 10, 'image': 'assets/toys2.jpg'},
  {'name': 'Toy', 'category': 'Toys', 'price': 10, 'image': 'assets/toys3.jpg'},
  {
    'name': 'Toy Car',
    'category': 'Toys',
    'price': 10,
    'image': 'assets/toys4.jpg'
  },
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  final stt.SpeechToText _speech = stt.SpeechToText();

  void _searchProducts(String query) {
    setState(() {
      searchResults = products.where((product) {
        return product['name']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _startVoiceSearch() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Voice Search Status: $status'),
      onError: (errorNotification) =>
          print('Voice Search Error: $errorNotification'),
    );

    if (available) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
            _searchProducts(result.recognizedWords);
          });
        },
      );
    }
  }

  void _stopVoiceSearch() {
    _speech.stop();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Shopping'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const CartScreen()));
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                await prefs.setBool('isAdmin', false);
                Navigator.pushReplacementNamed(context, "/");
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: _searchProducts,
                  ),
                ),
                IconButton(
                  icon: Icon(_speech.isListening ? Icons.mic_off : Icons.mic),
                  onPressed: () {
                    if (_speech.isListening) {
                      _stopVoiceSearch();
                    } else {
                      _startVoiceSearch();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _searchController.text.isEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (ctx, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  ProductScreen(categories[index]['name']!),
                            ),
                          );
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
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  categories[index]['name']!,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (ctx, index) {
                      final product = searchResults[index];
                      return ListTile(
                        leading: Image.asset(product['image']!,
                            width: 50, height: 50),
                        title: Text(product['name']!),
                        subtitle: Text('\$${product['price']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            Cart.addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${product['name']} added to cart!')),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ProductScreen extends StatelessWidget {
  final String categoryName;

  const ProductScreen(this.categoryName, {super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProducts = products
        .where((product) => product['category'] == categoryName)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Products in $categoryName'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categoryProducts.length,
        itemBuilder: (ctx, index) {
          return Card(
            elevation: 5,
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    categoryProducts[index]['image']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        categoryProducts[index]['name']!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('\$${categoryProducts[index]['price']}'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    Cart.addToCart(categoryProducts[index]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${categoryProducts[index]['name']} added to cart!')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
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
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          Cart.decreaseQuantity(item);
                          (context as Element).markNeedsBuild();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Cart.increaseQuantity(item);
                          (context as Element).markNeedsBuild();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
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
            padding: const EdgeInsets.all(10),
            child: Text(
              'Total: \$${Cart.calculateTotal()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Order Submitted'),
                  content: const Text('Thank you for your order!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Cart.clearCart();
                        (context as Element).markNeedsBuild();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Checkout'),
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
      (total, item) =>
          (total + (item['price'] ?? 0) * (item['quantity'] ?? 0)).toInt(),
    );
  }

  static void clearCart() {
    cartItems.clear();
  }
}
