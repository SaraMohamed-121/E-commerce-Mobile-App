import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => ReportState();
}

class ReportState extends State<Report> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String date = "";
  List<Map<String, dynamic>> transactions = [];

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        date = "${pickedDate.toLocal()}".split(' ')[0];
      });

      getReportData(date);
    }
  }

  Future<void> getReportData(String date) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Transaction')
          .where('purchaseDate', isEqualTo: date)
          .get();

      setState(() {
        transactions = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => selectDate(context),
              child: const Text('Select Date'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Selected Date: $date',
                style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text('No transactions found for this date'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transaction = transactions[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('Product: ${transaction['product']}'),
                          subtitle:
                              Text('Username: ${transaction['username']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Quantity: ${transaction['quantity']}'),
                              Text('Total: \$${transaction['totalPrice']}'),
                            ],
                          ),
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
