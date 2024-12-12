// New Panel: StarPanel
import 'package:flutter/material.dart';
import 'product_page.dart';

class rating_page extends StatelessWidget {
  final Product product;

  const rating_page({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating Panel'),
      ),
    );
  }
}
