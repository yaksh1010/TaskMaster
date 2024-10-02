import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminTodoPage extends StatefulWidget {
  const AdminTodoPage({super.key});

  @override
  State<AdminTodoPage> createState() => _AdminTodoPageState();
}

class _AdminTodoPageState extends State<AdminTodoPage> {
  final String adminId = 'fixedAdminId'; // Replace with the fixed admin ID

  // Build the task list widget for ToDo tasks
  Widget _buildTaskList() {
    // Stream for real-time updates of ToDo tasks
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Admin').doc(adminId).collection('ToDo').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No tasks available'));
        }

        final tasks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final taskDeadlineTimestamp = task['deadline'] as Timestamp?;
            final taskDeadline =
                taskDeadlineTimestamp != null ? DateFormat.yMMMd().format(taskDeadlineTimestamp.toDate()) : 'No Deadline';

            final taskTitle = task['taskName'] ?? 'No Title';
            final taskDescription = task['taskDetails'] ?? 'No Description';
            final taskId = task.id;

            return Dismissible(
              key: Key(taskId),
              background: _buildDismissibleBackground(Colors.green, Icons.check, "Mark as Complete"), // Left swipe background
              secondaryBackground: _buildDismissibleBackground(Colors.red, Icons.delete, "Delete"), // Right swipe background
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return await _confirmCompletion(context);
                } else {
                  return await _confirmDeletion(context);
                }
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  // Swipe left - Delete the task
                  _deleteTask(taskId);
                } else if (direction == DismissDirection.startToEnd) {
                  // Swipe right - Mark as complete
                  _moveToCompleted(taskId, taskTitle, taskDescription);
                }
              },
              child: Card(
                color: Colors.white30,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1), // Thin black border
                  borderRadius: BorderRadius.circular(16), // Circular rectangle shape
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: ListTile(
                  trailing: Text(
                    taskDeadline,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  title: Text(
                    taskTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(taskDescription),
                  onTap: () {
                    // Navigate to task details or perform another action
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper function to build dismissible background for swipe actions
  Widget _buildDismissibleBackground(Color color, IconData icon, String text) {
    return Container(
      color: color,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }

  // Function to delete a task
  Future<void> _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('Admin').doc(adminId).collection('ToDo').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  // Function to move a task to the completed list
  Future<void> _moveToCompleted(String taskId, String taskTitle, String taskDescription) async {
    try {
      await FirebaseFirestore.instance.collection('Admin').doc(adminId).collection('CompletedToDo').add({
        'taskName': taskTitle,
        'taskDetails': taskDescription,
        'completedOn': Timestamp.now(),
      });
      await _deleteTask(taskId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task marked as complete')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error moving task to completed: $e')),
      );
    }
  }

  // Function to confirm deletion
  Future<bool> _confirmDeletion(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Task'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Function to confirm completion
  Future<bool> _confirmCompletion(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Mark as Complete'),
              content: const Text('Are you sure you want to mark this task as complete?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Mark as Complete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin ToDo Tasks'),
      ),
      body: _buildTaskList(),
    );
  }
}
