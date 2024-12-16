import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class Chart extends StatelessWidget {
  const Chart({super.key});

  Future<List<ProductData>> fetchProductData() async {
    final databaseRef = FirebaseDatabase.instance.ref();
    try {
      DatabaseReference productsRef = databaseRef.child('products');
      DataSnapshot snapshot = await productsRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> products =
            snapshot.value as Map<dynamic, dynamic>;

        return products.entries.map((entry) {
          final key = entry.key;
          final value = entry.value as Map<dynamic, dynamic>;
          return ProductData(
            key,
            (value['quantity'] ?? 0) as int,
          );
        }).toList();
      } else {
        print("No products found in the database.");
        return [];
      }
    } catch (error) {
      print("Error fetching products: $error");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Chart'),
      ),
      body: FutureBuilder<List<ProductData>>(
        future: fetchProductData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Prepare data for pie chart
            final totalQuantity =
                snapshot.data!.fold<int>(0, (sum, item) => sum + item.quantity);

            final bestSelling = snapshot.data!
                .reduce((a, b) => a.quantity > b.quantity ? a : b);

            // Prepare data for the bar chart
            List<BarChartGroupData> barGroups = snapshot.data!.map((product) {
              return BarChartGroupData(
                x: snapshot.data!.indexOf(product),
                barRods: [
                  BarChartRodData(
                    toY: product.quantity.toDouble(),
                    color: Colors.blue,
                    width: 20,
                    borderRadius: BorderRadius.zero,
                    // titlesData: FlTitlesData(
                    //   bottomTitles: AxisTitles(
                    //     sideTitles: SideTitles(
                    //       showTitles: true,
                    //       getTitlesWidget: (double value, TitleMeta meta) {
                    //         final index = value.toInt();
                    //         if (index >= 0 && index < snapshot.data!.length) {
                    //           return Text(snapshot.data![index].name,
                    //               style: const TextStyle(fontSize: 10));
                    //         }
                    //         return const Text('');
                    //       },
                    //     ),
                    //   ),
                    //   leftTitles: AxisTitles(
                    //     sideTitles: SideTitles(showTitles: true),
                    //   ),
                    // ),
                  ),
                ],
              );
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Quantities: $totalQuantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Most Popular Product: ${bestSelling.name} (${bestSelling.quantity})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bar chart section
                  Center(
                    child: SizedBox(
                      width: 350,
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: const FlTitlesData(show: true),
                          borderData: FlBorderData(show: true),
                          barGroups: barGroups,
                        ),
                      ),
                    ),
                  ),

                  // Pie chart Section
                  Center(
                    child: SizedBox(
                      height: 350,
                      child: PieChart(
                        PieChartData(
                          sections: snapshot.data!.map(
                            (product) {
                              final percentage =
                                  (product.quantity / totalQuantity * 100)
                                      .toStringAsFixed(1);
                              return PieChartSectionData(
                                title: '${product.name}',
                                value: product.quantity.toDouble(),
                                color: Colors.primaries[
                                    snapshot.data!.indexOf(product) %
                                        Colors.primaries.length],
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ).toList(),
                          centerSpaceRadius: 90,
                          sectionsSpace: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('No products available.'),
            );
          }
        },
      ),
    );
  }
}

class ProductData {
  final String name;
  final int quantity;

  ProductData(this.name, this.quantity);
}
