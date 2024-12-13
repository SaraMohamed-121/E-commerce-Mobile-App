import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'category_page.dart';
import 'product_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Future<void>main() async{
//   WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
//     runApp(const MyApp());
// }
class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text('Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
                StreamBuilder<QuerySnapshot>(
                  stream : FirebaseFirestore.instance.collection('Category').snapshots(),
                  builder: (context,snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text(
                        'No categories added yet.',
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    final categoryDocs = snapshot.data!.docs;
                    return Column(
                      children: categoryDocs.map((doc) {
                        final category = doc['name'] ?? 'unamed';
                        return ListTile(
                          leading: const Icon(Icons.category),
                          title: Text(category),
                        );
                      }).toList(),
                    );
                  },
                ),
                const Divider(),
                const Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Product').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text(
                        'No products added yet.',
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    final productDocs = snapshot.data!.docs;
                    return Column(
                      children: productDocs.map((doc) {
                        final product = Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                        return ListTile(
                          leading: const Icon(Icons.shopping_cart),
                          title: Text(product.name),
                          subtitle: Text('Category: ${product.category}'),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Price: \$${product.price.toStringAsFixed(2)}'),
                              Text('Stock: ${product.stock}'),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoryPage()),
                  );
                  setState(() {});
                },
                child: const Text('Manage Categories'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductPage()),
                  );
                  setState(() {});
                },
                child: const Text('Manage Products'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



