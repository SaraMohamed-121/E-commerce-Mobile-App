import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'product_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  final stt.SpeechToText _speech = stt.SpeechToText();

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('Product')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    setState(() {
      searchResults = snapshot.docs.map((doc) => doc.data()).toList();
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
            _searchController.text = result.recognizedWords.replaceAll('.', '');
            _searchProducts(_searchController.text);
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
                ElevatedButton(
                  onPressed: () async {
                    String? res = await SimpleBarcodeScanner.scanBarcode(
                      context,
                      barcodeAppBar: const BarcodeAppBar(
                        appBarTitle: 'Scan',
                        centerTitle: false,
                        enableBackButton: true,
                        backButtonIcon: Icon(Icons.arrow_back_ios),
                      ),
                      isShowFlashIcon: true,
                      delayMillis: 2000,
                      cameraFace: CameraFace.front,
                    );
                    if (res != null) {
                      print(res);
                      try {
                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('Product')
                            .where('qr', isEqualTo: res)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          String name = querySnapshot.docs.first.get('name');
                          print('Name: $name');
                          _searchController.text = name;
                          _searchProducts(_searchController.text);
                        } else {
                          print('No document found with qr: $res');
                        }
                      } catch (e) {
                        print('Error fetching data: $e');
                      }
                    } else {
                      print('Scanning canceled or failed.');
                    }
                  },
                  child: const Text('Barcode'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _searchController.text.isEmpty
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Category')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No categories found'));
                      }

                      final categories = snapshot.data!.docs
                          .map((doc) => doc.data() as Map<String, dynamic>)
                          .toList();

                      return GridView.builder(
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
                                  builder: (ctx) => ProductScreen(
                                      categories[index]['name']..toString()),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      categories[index]['image'] ?? '',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.image),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      categories[index]['name'] ??
                                          'Unnamed Category',
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
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (ctx, index) {
                      final product = searchResults[index];
                      return ListTile(
                        leading: Image.network(product['image']!,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Products in $categoryName'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Product')
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final categoryProducts = snapshot.data!.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  })
              .toList();

          return GridView.builder(
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
                      child: Image.network(
                        categoryProducts[index]['image'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            categoryProducts[index]['name'] ??
                                'Unnamed Product',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text('\$${categoryProducts[index]['price'] ?? 0}'),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            Cart.addToCart(categoryProducts[index]);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${categoryProducts[index]['name']} added to cart!'),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.feedback),
                          onPressed: () {
                            _showFeedbackDialog(
                                context, categoryProducts[index]['id']);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
  }

  void _showFeedbackDialog(BuildContext context, String productId) {
    final TextEditingController feedbackController = TextEditingController();
    double rating = 3.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Leave Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: 3.0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  hintText: 'Write your feedback here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final feedback = feedbackController.text.trim();

                if (feedback.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback cannot be empty!')),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('Product')
                    .doc(productId)
                    .update({
                  'feedbacks': FieldValue.arrayUnion([feedback]),
                  'ratings': FieldValue.arrayUnion([rating]),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your feedback!')),
                );

                Navigator.of(ctx).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
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
              Cart.storeInfo(); // Store the user's transaction to generate the report
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

  static Future<void> increaseQuantity(Map<String, dynamic> product) async {
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

  static void storeInfo() async {
    final db = FirebaseDatabase.instance.ref();
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    DateTime dateTime = DateTime.now();
    String date = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

    ProductPageState p = ProductPageState();
    for (var item in cartItems) {
      String productName = item['name'];
      int quantity = item['quantity'], newQuantity = 0;
      int price = (item['price'] ?? 0) * (item['quantity'] ?? 0);

      DataSnapshot snapshot =
          await db.child('products/$productName/quantity').get();
      if (snapshot.exists) {
        newQuantity = int.parse(snapshot.value.toString()) + quantity;
      } else {
        newQuantity = quantity;
      }

      db.child('products').child(productName).set({
        'quantity': newQuantity,
      });

      p.addTransaction(username, productName, quantity, price, date);
    }
  }

  static void clearCart() {
    cartItems.clear();
  }
}
