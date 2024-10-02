import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmaster/admin/admin_taskDetail.dart';

class AdminTaskView extends StatelessWidget {
  const AdminTaskView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Task Assignment'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userId = userDoc.id;
              final userName = userDoc['Name'];

              return UserSection(userId: userId, userName: userName);
            },
          );
        },
      ),
    );
  }
}

class UserSection extends StatelessWidget {
  final String userId;
  final String userName;

  const UserSection({required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Tasks').where('assignedUser', isEqualTo: userName).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final tasks = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final taskItem = tasks[index];

                  return TaskItemTile(taskItem: taskItem);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class TaskItemTile extends StatelessWidget {
  final QueryDocumentSnapshot taskItem;

  const TaskItemTile({required this.taskItem});

  @override
  Widget build(BuildContext context) {
    // Extracting task details and status
    final taskName = taskItem.get('taskName') ?? 'Unnamed Task';
    final taskDetail = taskItem.get('taskDetails') ?? 'No details available';
    final taskStatus = taskItem.get('status') ?? 'Assigned'; // Default status
    final taskPriority = taskItem.get('priority') ?? 'Low'; // Default priority

    // Determine the background color based on the task status
    Color _getStatusColor(String status) {
      switch (status) {
        case 'Completed':
          return Colors.green;
        case 'In Progress':
          return const Color.fromARGB(255, 253, 229, 5);
        case 'On Hold':
          return Colors.orange;
        case 'Assigned':
        default:
          return const Color.fromARGB(133, 252, 234, 121);
      }
    }

    // Determine the color of the circle based on priority
    Color _getPriorityColor(String priority) {
      switch (priority) {
        case 'High':
          return Colors.red;
        case 'Medium':
          return Colors.orange;
        case 'Low':
        default:
          return Colors.green;
      }
    }

    return Dismissible(
      key: Key(taskItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerEnd,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showConfirmationDialog(context);
      },
      onDismissed: (direction) {
        _deleteTask(taskItem.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$taskName deleted')),
        );
      },
      child: GestureDetector(
        onTap: () {
          // Navigate to TaskDetailPage and pass the task item
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminTaskDetailPage(taskItem: taskItem),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: _getStatusColor(taskStatus), // Set background color based on status
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(
                    taskName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(
                    taskDetail,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getPriorityColor(taskPriority), // Set color based on priority
                    border: Border.all(color: Colors.black, width: 2), // Black border
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios),
              const SizedBox(width: 10,)
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel deletion
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(String taskId) {
    FirebaseFirestore.instance.collection('Tasks').doc(taskId).delete();
  }
}

