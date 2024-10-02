import 'dart:io'; // Import for platform detection
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({Key? key}) : super(key: key);

  @override
  _AdminOrdersState createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  late Stream<QuerySnapshot> ordersStream;

  @override
  void initState() {
    super.initState();
    ordersStream = FirebaseFirestore.instance.collection("FinalOrders").orderBy('date', descending: true).snapshots();
  }

  Future<void> _saveOrder(DocumentSnapshot order) async {
    try {
      // Save the order to "CompletedOrders"
      await FirebaseFirestore.instance.collection("CompletedOrders").doc(order.id).set(order.data() as Map<String, dynamic>);

      // Delete the order from "FinalOrders"
      await FirebaseFirestore.instance.collection("FinalOrders").doc(order.id).delete();
    } catch (e) {
      print('Failed to save order: $e');
    }
  }

  Future<bool?> _showSaveConfirmation() async {
    if (Platform.isIOS) {
      // iOS-style alert
      return await showDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Confirm Save'),
          content: Text('Are you sure you want to save this order?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Save'),
            ),
          ],
        ),
      );
    } else {
      // Android-style alert
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Save'),
          content: Text('Are you sure you want to save this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Orders'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No orders found'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot order = snapshot.data!.docs[index];
              String orderId = order.id;

              return Dismissible(
                key: ValueKey(orderId),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  final result = await _showSaveConfirmation();
                  if (result == true) {
                    await _saveOrder(order);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order saved')),
                    );
                    return true;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order save cancelled'),
                      ),
                    );
                    return false;
                  }
                },
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.save, color: Colors.white),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space between children
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order ID: ${order['OrderID']}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Name: ${order['itemName']}'),
                                  Text('Quantity: ${order['quantity']}'),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('Ready'),
                            ),
                          ],
                        )),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
