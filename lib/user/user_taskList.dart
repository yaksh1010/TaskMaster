import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/user/user_taskDetail.dart'; // Update with your actual file path

class TaskListPage extends StatelessWidget {
  final String status;

  TaskListPage({required this.status});

  Future<String?> getUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('No user is logged in');
    }

    // Fetch user data from Firestore
    final userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).get();

    if (!userSnapshot.exists) {
      throw Exception('User data not found');
    }

    final userName = userSnapshot['Name'] as String?;
    return userName;
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showChangeStatusBottomSheet(BuildContext context, String taskId, String currentStatus) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Assigned'),
                onTap: () => _updateTaskStatus(context, taskId, 'Assigned'),
              ),
              ListTile(
                title: Text('In Progress'),
                onTap: () => _updateTaskStatus(context, taskId, 'In Progress'),
              ),
              ListTile(
                title: Text('On Hold'),
                onTap: () => _updateTaskStatus(context, taskId, 'On Hold'),
              ),
              ListTile(
                title: Text('Completed'),
                onTap: () => _updateTaskStatus(context, taskId, 'Completed'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddCommentDialog(BuildContext context, String taskId, String currentComment) async {
    final TextEditingController commentController = TextEditingController(text: currentComment);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Enter your comment here'),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateTaskComment(context, taskId, commentController.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateTaskStatus(BuildContext context, String taskId, String newStatus) async {
    await FirebaseFirestore.instance.collection('Tasks').doc(taskId).update({'status': newStatus});
  }

  Future<void> _updateTaskComment(BuildContext context, String taskId, String newComment) async {
    await FirebaseFirestore.instance.collection('Tasks').doc(taskId).update({'comments': newComment});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserName(), // Fetch the user's name asynchronously
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('$status Tasks'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('$status Tasks'),
            ),
            body: Center(child: Text('Error: ${userSnapshot.error}')),
          );
        }

        final userName = userSnapshot.data;
        if (userName == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('$status Tasks'),
            ),
            body: Center(child: Text('User data not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('$status Tasks'),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Tasks')
                .where('assignedUser', isEqualTo: userName) // Filter by current user
                .where('status', isEqualTo: status) // Filter by task status
                .snapshots(),
            builder: (context, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (taskSnapshot.hasError) {
                return Center(child: Text('Error: ${taskSnapshot.error}'));
              }

              if (taskSnapshot.data == null || taskSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No tasks available'));
              }

              return ListView.builder(
                itemCount: taskSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final taskItem = taskSnapshot.data!.docs[index];
                  final priority = taskItem['priority']; // Assuming priority is stored in 'priority' field
                  final priorityColor = getPriorityColor(priority);
                  final taskId = taskItem.id; // Use task ID to update

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task name
                          Text(
                            taskItem['taskName'],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),

                          // Task details
                          Text(
                            taskItem['taskDetails'],
                            style: TextStyle(fontSize: 16), // Adjusted font size for better readability
                            maxLines: 3, // Limit to 3 lines
                            overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                            softWrap: true, // Allow text to wrap across multiple lines
                          ),
                        ],
                      ),
                      
                      trailing: PopupMenuButton<String>(
                        onSelected: (String value) {
                          if (value == 'Change Status') {
                            _showChangeStatusBottomSheet(context, taskId, taskItem['status']);
                          } else if (value == 'Add Comment') {
                            _showAddCommentDialog(context, taskId, taskItem['comments']);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'Change Status',
                              child: Text('Change Status'),
                            ),
                            PopupMenuItem<String>(
                              value: 'Add Comment',
                              child: Text('Add Comment'),
                            ),
                          ];
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserTaskDetailPage(taskItem: taskItem),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
