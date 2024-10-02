import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // To format dates

class CompletedTasksPage extends StatefulWidget {
  const CompletedTasksPage({Key? key}) : super(key: key);

  @override
  _CompletedTasksPageState createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
  late Stream<QuerySnapshot> completedOrdersStream;

  @override
  void initState() {
    super.initState();
    completedOrdersStream = FirebaseFirestore.instance
        .collection("Tasks")
        .where('status', isEqualTo: 'Completed') // Fetch tasks with status as completed
        .orderBy('deadline', descending: true) // Ensure latest dates come first
        .snapshots();
  }

  String formatDate(DateTime date) {
    return DateFormat('MM-dd-yyyy').format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: Text(
          'Completed Tasks',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: completedOrdersStream,
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
              child: Text('No completed tasks found'),
            );
          }

          // Group tasks by date
          Map<String, List<DocumentSnapshot>> groupedTasks = {};
          for (var doc in snapshot.data!.docs) {
            DateTime timestamp = (doc['deadline'] as Timestamp).toDate();
            String date = formatDate(timestamp);
            if (groupedTasks[date] == null) {
              groupedTasks[date] = [];
            }
            groupedTasks[date]!.add(doc);
          }

          List<String> sortedDates = groupedTasks.keys.toList()..sort((a, b) => b.compareTo(a)); // Sort dates in descending order

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              String date = sortedDates[index];
              List<DocumentSnapshot> tasks = groupedTasks[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.grey[700], thickness: 1.0), // Dark grey line above the date
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Color.fromARGB(255, 103, 160, 225),
                    child: Text(
                      date,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Divider(color: Colors.grey[700], thickness: 1.0), // Dark grey line below the date
                  ...tasks.map((task) {
                    DateTime timestamp = (task['deadline'] as Timestamp).toDate();
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3), // Changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name: ${task['taskName']}', // Change to your actual field name
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Details: ${task['taskDetails']}', // Change to your actual field name
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                             const  Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
