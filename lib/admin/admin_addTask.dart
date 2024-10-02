import 'dart:io';
import 'package:taskmaster/database/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart'; // For date formatting

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  // Controllers for TextFields
  TextEditingController taskNameController = TextEditingController(); // Controller for task name
  TextEditingController taskDetailsController = TextEditingController(); // Controller for task details

  String? selectedUser;
  String? selectedPriority;
  DateTime? deadline;

  List<String> users = [];
  bool isLoadingUsers = true;

  final List<String> priorities = ['Low', 'Medium', 'High'];

  Future<void> getUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Users').get();
      setState(() {
        users = snapshot.docs.map((doc) => doc['Name'] as String).toList();
        isLoadingUsers = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoadingUsers = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != deadline) {
      setState(() {
        deadline = picked;
      });
    }
  }

  Future<void> addTaskToFirestore() async {
    if (taskNameController.text.isEmpty ||
        taskDetailsController.text.isEmpty ||
        selectedUser == null ||
        selectedPriority == null ||
        deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    try {
      String taskId = randomAlphaNumeric(10);
      DateTime currentTime = DateTime.now();

      Map<String, dynamic> taskData = {
        'taskName': taskNameController.text,
        'taskDetails': taskDetailsController.text,
        'assignedUser': selectedUser,
        'priority': selectedPriority,
        'deadline': deadline,
        'createdOn': currentTime,
        'status' : "Assigned",
        'comments' : "",
      };

      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).set(taskData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully!')),
      );

      // Clear all fields
      setState(() {
        taskNameController.clear(); // Clear task name
        taskDetailsController.clear(); // Clear task details
        selectedUser = null;
        selectedPriority = null;
        deadline = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add new task"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Task Name"),
              const SizedBox(height: 10.0),
              TextField(
                controller: taskNameController, // Use the controller for task name
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFececf8),
                  hintText: "Enter Task Name",
                ),
              ),
              const SizedBox(height: 20.0),
              const Text("Task Details"),
              const SizedBox(height: 10.0),
              TextField(
                controller: taskDetailsController, // Use the controller for task details
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFececf8),
                  hintText: "Enter Task Details",
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20.0),
              const Text("Deadline"),
              const SizedBox(height: 10.0),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFececf8),
                  hintText: deadline != null ? DateFormat.yMMMd().format(deadline!) : "Select Deadline",
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () {
                  selectDeadline(context);
                },
              ),
              const SizedBox(height: 20.0),
              const Text("Assign Task to User"),
              const SizedBox(height: 10.0),
              isLoadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : users.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: const Color(0xFFececf8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              items: users
                                  .map((user) => DropdownMenuItem<String>(
                                        value: user,
                                        child: Text(
                                          user,
                                          style: const TextStyle(fontSize: 18.0, color: Colors.black),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (user) {
                                setState(() {
                                  selectedUser = user;
                                });
                              },
                              dropdownColor: Colors.white,
                              hint: const Text("Select User"),
                              iconSize: 36,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                              value: selectedUser,
                            ),
                          ),
                        )
                      : const Center(child: Text("No users available")),
              const SizedBox(height: 20.0),
              const Text("Task Priority"),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items: priorities
                        .map((priority) => DropdownMenuItem<String>(
                              value: priority,
                              child: Text(
                                priority,
                                style: const TextStyle(fontSize: 18.0, color: Colors.black),
                              ),
                            ))
                        .toList(),
                    onChanged: (priority) {
                      setState(() {
                        selectedPriority = priority;
                      });
                    },
                    dropdownColor: Colors.white,
                    hint: const Text("Select Priority"),
                    iconSize: 36,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    value: selectedPriority,
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              GestureDetector(
                onTap: addTaskToFirestore,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Add Task",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
