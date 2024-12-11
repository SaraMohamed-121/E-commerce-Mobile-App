// New Panel: StarPanel
import 'package:flutter/material.dart';
import 'product_page.dart';
class rating_page extends StatelessWidget {
  final Product product;

  const rating_page({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rating Panel'),
      ),
    );
  }
}
