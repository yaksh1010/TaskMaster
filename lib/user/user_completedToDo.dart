import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserCompletedToDo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed ToDo', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // Back button color
        elevation: 0,
      ),
      body: _buildCompletedTaskList(),
    );
  }

  // Build the task list widget for CompletedToDo tasks
  Widget _buildCompletedTaskList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(child: Text('No user is logged in'));
    }

    // Stream for real-time updates of CompletedToDo tasks
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).collection('CompletedToDo').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No completed tasks available'));
        }

        final completedTasks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: completedTasks.length,
          itemBuilder: (context, index) {
            final task = completedTasks[index];
            final taskTitle = task['taskName'] ?? 'No Title'; // Replace 'taskName' with the actual field name
            final taskDescription = task['taskDetails'] ?? 'No Description'; // Replace 'taskDetails' with the actual field name
            final completionDate = task['completedAt'] as Timestamp?; // Ensure timestamp field exists

            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.black.withOpacity(0.5), width: 1),
              ),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(taskTitle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(taskDescription),
                    if (completionDate != null)
                      Text(
                        'Completed on: ${_formatDate(completionDate.toDate())}',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                  ],
                ),
                onTap: () {
                  // Optionally, navigate to task details or perform other actions
                },
              ),
            );
          },
        );
      },
    );
  }

  // Format the timestamp to a readable date
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
