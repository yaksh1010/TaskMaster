import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserTaskDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot taskItem;

  const UserTaskDetailPage({Key? key, required this.taskItem}) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<UserTaskDetailPage> {
  late String taskStatus;
  late String taskComments;

  @override
  void initState() {
    super.initState();
    taskStatus = widget.taskItem.get('status') ?? 'Pending';
    taskComments = widget.taskItem.get('comments') ?? 'No comments available';
  }

  @override
  Widget build(BuildContext context) {
    // Fetching all details from the task document
    final taskName = widget.taskItem.get('taskName') ?? 'Unnamed Task';
    final taskDetail = widget.taskItem.get('taskDetails') ?? 'No details available';
    final taskDueDate = widget.taskItem.get('deadline') ?? 'No due date';
    final createdOn = widget.taskItem.get('createdOn') ?? 'No assigned date';
    final taskAssignedUser = widget.taskItem.get('assignedUser') ?? 'Unassigned';
    final taskPriority = widget.taskItem.get('priority') ?? 'No priority set';

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

    // Determine the color based on the priority
    Color getPriorityColor(String priority) {
      switch (priority) {
        case 'High':
          return Colors.red.withOpacity(0.7);
        case 'Medium':
          return Colors.orange.withOpacity(0.7);
        case 'Low':
          return Colors.green.withOpacity(0.7);
        default:
          return Colors.grey.withOpacity(0.5);
      }
    }

    // Create a reusable method for container decoration with a circular rectangle shape
    Widget _buildContainer(String label, String content, {Color? backgroundColor}) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
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
                const SizedBox(width: 10),
                Expanded(child: _buildContainer('Details:', taskDetail)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildContainer('Employee:', taskAssignedUser)),
                const SizedBox(width: 10),
                Expanded(child: _buildContainer('Priority:', taskPriority, backgroundColor: getPriorityColor(taskPriority))),
                const SizedBox(width: 10),
                Expanded(child: _buildContainer('Status:', taskStatus)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildContainer('Assigned On:', formattedCreatedDate)),
                const SizedBox(width: 10),
                Expanded(child: _buildContainer('Deadline:', formattedDueDate)),
              ],
            ),
            // Comments section in a separate circular rectangle container
            SizedBox(
              child: _buildContainer('Comments:', taskComments),
              height: 170,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  // Method to show the dialog for editing status and comments
}