import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingPage extends StatelessWidget {
  final String productId;

  const RatingPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Reviews"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Product')
                    .doc(productId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      !snapshot.data!.exists) {
                    return const Center(child: Text("No reviews found."));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final feedbacks = data['feedbacks'] as List<dynamic>? ?? [];
                  final ratings = data['ratings'] as List<dynamic>? ?? [];

                  if (feedbacks.isEmpty || ratings.isEmpty) {
                    return const Center(child: Text("No reviews yet."));
                  }

                  return ListView.builder(
                    itemCount: feedbacks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final comment = feedbacks.length > index
                          ? feedbacks[index]
                          : "No comment";
                      final rating = ratings.length > index
                          ? (ratings[index] as num).toDouble()
                          : 0.0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: const Icon(Icons.person, size: 40),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingBarIndicator(
                                rating: rating,
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                                direction: Axis.horizontal,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                comment.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
