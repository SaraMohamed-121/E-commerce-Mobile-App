import 'package:flutter/material.dart';
import 'category_page.dart';
import 'product_page.dart';

void main() {
  runApp(MyApp());
}

final List<String> categories = [];
final List<Product> products = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Text('Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (categories.isEmpty)
                  Text('No categories added yet.', style: TextStyle(color: Colors.grey)),
                ...categories.map((category) => ListTile(
                      leading: Icon(Icons.category),
                      title: Text(category),
                    )),
                Divider(),
                Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (products.isEmpty)
                  Text('No products added yet.', style: TextStyle(color: Colors.grey)),
                ...products.map((product) => ListTile(
                      leading: Icon(Icons.shopping_cart),
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
                    )),
              ],
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryPage()),
                  );
                  setState(() {}); 
                },
                child: Text('Manage Categories'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductPage()),
                  );
                  setState(() {}); 
                },
                child: Text('Manage Products'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



