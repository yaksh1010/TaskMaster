import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AdminTaskDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot taskItem;

  const AdminTaskDetailPage({Key? key, required this.taskItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetching all details from the task document
    final taskName = taskItem.get('taskName') ?? 'Unnamed Task';
    final comments = taskItem.get('comments') ?? 'No comments available';
    final taskDetail = taskItem.get('taskDetails') ?? 'No details available';
    final taskDueDate = taskItem.get('deadline') ?? 'No due date';
    final createdOn = taskItem.get('createdOn') ?? 'No assigned date';
    final taskAssignedUser = taskItem.get('assignedUser') ?? 'Unassigned';
    final taskPriority = taskItem.get('priority') ?? 'No priority set';
    final taskStatus = taskItem.get('status') ?? 'Pending';

    // Format deadline if it's a Timestamp
    String formattedDueDate = 'No due date';
    if (taskDueDate is Timestamp) {
      final dateTime = (taskDueDate as Timestamp).toDate();
      formattedDueDate = DateFormat.yMMMd().format(dateTime);
    }

    String formattedCreatedDate = 'No assigned date';
    if (createdOn is Timestamp) {
      final dateTime1 = (createdOn as Timestamp).toDate();
      formattedCreatedDate = DateFormat.yMMMd().format(dateTime1);
    }

    // Create a reusable method for container decoration with a circular rectangle shape
    Widget _buildContainer(String label, String content) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15), // Circular rectangle shape
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              content,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(taskName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Name and Details in separate circular rectangle containers
            Row(
              children: [

                Expanded(child: _buildContainer('Task Name:', taskName)),
                const SizedBox(
                  width: 10,
                ),
                Expanded(child: _buildContainer('Details:', taskDetail)),
                
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildContainer('Employee:', taskAssignedUser)),
                const SizedBox(
                  width: 10,
                ),
                Expanded(child: _buildContainer('Priority:', taskPriority)),
                const SizedBox(
                  width: 10,
                ),
                Expanded(child: _buildContainer('Status:', taskStatus)),
                
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildContainer('Assigned On', formattedCreatedDate)),
                const SizedBox(
                  width: 10,
                ),
                Expanded(child: _buildContainer('Deadline:', formattedDueDate)),
              ],
            ),
            // Comments section in a separate circular rectangle container
            SizedBox(child: _buildContainer('Comments:', comments),
            height: 170,
            width: double.infinity,
            ),
            
          ],
        ),
      ),
    );
  }
}
