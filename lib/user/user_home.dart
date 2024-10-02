import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/user/user_taskList.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontFamily: AutofillHints.addressState,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The fixed-height GridView for status cards
            SizedBox(
              height: 380, // Adjust the height to fit your design needs
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                physics: NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                children: [
                  _buildStatusCard(context, 'Assigned', 'Assigned'),
                  _buildStatusCard(context, 'In Progress', 'In Progress'),
                  _buildStatusCard(context, 'On Hold', 'On Hold'),
                  _buildStatusCard(context, 'Completed', 'Completed'),
                ],
              ),
            ),
            //const SizedBox(height: 20),
            const Text("ToDo List",style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: AutofillHints.birthdayMonth, 
            ),),
            const SizedBox(height: 20,),
            Expanded(
              child: _buildTaskList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _taskStream(status), // Real-time task stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading while data is being fetched
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final taskCount = snapshot.data?.size ?? 0;

        Color color;
        switch (status) {
          case 'Assigned':
            color = Color.fromARGB(255, 253, 211, 1);
            break;
          case 'In Progress':
            color = Color.fromARGB(255, 255, 120, 2);
            break;
          case 'On Hold':
            color = Color.fromARGB(255, 255, 0, 0);
            break;
          case 'Completed':
            color = Color.fromARGB(255, 98, 255, 0);
            break;
          default:
            color = Colors.grey;
        }

        return GestureDetector(
          onTap: () {
            _navigateToTaskList(context, status); // Navigate to task list page based on status
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          taskCount.toString(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Icon(Icons.more_horiz, color: color),
                      ],
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

 // Build the task list widget for ToDo tasks
  Widget _buildTaskList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(child: Text('No user is logged in'));
    }

    // Stream for real-time updates of ToDo tasks
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).collection('ToDo').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No tasks available'));
        }

        final tasks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final taskDeadlineTimestamp = task['deadline'] as Timestamp?;
            final taskDeadline =
                taskDeadlineTimestamp != null ? DateFormat.yMMMd().format(taskDeadlineTimestamp.toDate()) : 'No Deadline';

            final taskTitle = task['taskName'] ?? 'No Title'; // Replace 'taskName' with the actual field name
            final taskDescription = task['taskDetails'] ?? 'No Description'; // Replace 'taskDetails' with the actual field name
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
                  // Swipe left - Move to CompletedToDo
                  _deleteTask(taskId);
                } else if (direction == DismissDirection.startToEnd) {
                  // Swipe right - Delete from ToDo
                  _moveToCompleted(taskId, taskTitle, taskDescription);
                }
              },
              child: Card(
                color: Colors.white30,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black, width: 1), // Thin black border
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
                    style: TextStyle(fontWeight: FontWeight.w600),
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

// Function to build dismissible background for swipe action
  Widget _buildDismissibleBackground(Color color, IconData icon, String label) {
    return Container(
      alignment: Alignment.centerLeft,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

// Function to move a task to CompletedToDo collection
  void _moveToCompleted(String taskId, String taskTitle, String taskDescription) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
    final taskData = {
      'taskName': taskTitle,
      'taskDetails': taskDescription,
      'completedAt': Timestamp.now(),
    };

    // Add task to CompletedToDo collection
    await userDoc.collection('CompletedToDo').doc(taskId).set(taskData);

    // Remove task from ToDo collection
    await userDoc.collection('ToDo').doc(taskId).delete();
  }

// Function to delete a task from ToDo collection
  void _deleteTask(String taskId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).collection('ToDo').doc(taskId).delete();
  }

// Function to confirm deletion (swipe right)
  Future<bool> _confirmDeletion(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete Task"),
              content: Text("Are you sure you want to delete this task?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Delete"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

// Function to confirm task completion (swipe left)
  Future<bool> _confirmCompletion(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Mark as Complete"),
              content: Text("Are you sure you want to mark this task as completed?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Save"),
                ),
              ],
            );
          },
        ) ??
        false;
  }


  // Real-time stream to fetch the task count based on the user's name and task status
  Stream<QuerySnapshot> _taskStream(String status) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('No user is logged in');
    }

    return FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).snapshots().asyncExpand((userSnapshot) {
      if (!userSnapshot.exists) {
        throw Exception('User data not found');
      }

      final userName = userSnapshot['Name'];

      return FirebaseFirestore.instance
          .collection('Tasks')
          .where('assignedUser', isEqualTo: userName)
          .where('status', isEqualTo: status)
          .snapshots();
    });
  }



  // Navigate to the TaskListPage for tasks with the specified status
  void _navigateToTaskList(BuildContext context, String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskListPage(status: status),
      ),
    );
  }
}
