
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ratings & Reviews'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Review rev = new Review("ahmed","good",4);
class Review{
  String name;
  String desc;
  int stars;

  Review(this.name,this.desc,this.stars);
}
class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController controller1 = TextEditingController();
  static final List<Review> review = [rev];
  // void add() {
  //     setState(() {
  //     review.add(rev);
  //   });
  //}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body : Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children:[
          Expanded(
            child : ListView.builder(
            itemCount: review.length,
              itemBuilder: (BuildContext context, int index) { 
                return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                    leading: Icon(Icons.person,size: 40),
                    title: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(review[index].name),
                          
                          RatingBarIndicator(
                          rating: review[index].stars.toDouble(),
                          itemBuilder: (context, _) => 
                          const Icon(Icons.stars,color: Colors.amber),
                          itemCount: 5,
                          itemSize: 30.0,
                          direction: Axis.horizontal,),
                        ],
                    ),
                    subtitle: Text(review[index].desc),
                  ),
                );
               },
            )
            )
        ],
      ),
      )
      );
  }
}
