import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:taskmaster/authentication/login_screen.dart';
import 'package:taskmaster/database/auth.dart';
import 'package:taskmaster/database/shared_pref.dart';
import 'package:taskmaster/user/user_completedToDo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  String? name, email;
  String _userName = "Guest";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Fetch name and email from SharedPreferences
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();

    // Get the current user ID
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Fetch user name from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).get();

      // Check if the document exists and contains a 'Name' field
      if (userDoc['Name'] != null) {
        setState(() {
          _userName = userDoc['Name'];
        });
      } else {
        setState(() {
          _userName = name ?? "Guest"; // Fallback to shared preference or default value
        });
      }
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
              ),
            ],
          );
        }
      },
    );
  }

  void _deleteAccount() async {
    await AuthMethods().deleteuser();
    await SharedPreferenceHelper.setLoggedIn(false); // Set login state to false
    Get.offAll(() => const LoginScreen()); // Navigate to LoginScreen
  }

  void _logout() async {
    await AuthMethods().SignOut();
    await SharedPreferenceHelper.setLoggedIn(false); // Set login state to false
    Get.offAll(() => const LoginScreen()); // Navigate to LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Center(
        child: name == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20.0),
                    buildUserNameCard(),
                    const SizedBox(height: 20.0),
                    buildInfoCard(Icons.email, 'Account', email!),
                    const SizedBox(height: 30.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 2.0,
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        side: BorderSide(color: Colors.black, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserCompletedToDo(),
                            )); // Navigate to FeedbackPage
                      },
                      child: Row(
                        children: [
                          Icon(Icons.list, color: Colors.black),
                          const SizedBox(width: 20.0),
                          const Text(
                            'Completed ToDo',
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 20.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        elevation: 2.0,
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        side: BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        _showConfirmationDialog(
                          context,
                          'Delete Account',
                          'Are you sure you want to delete your account? This action cannot be undone.',
                          _deleteAccount,
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 20.0),
                          const Text(
                            'Delete Account',
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 20.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        elevation: 2.0,
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        side: BorderSide(color: Colors.blue, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        _showConfirmationDialog(
                          context,
                          'Log Out',
                          'Are you sure you want to log out?',
                          _logout,
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.blue),
                          const SizedBox(width: 20.0),
                          const Text(
                            'Log Out',
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 20.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Widget to display the user's name at the top of the profile screen
  Widget buildUserNameCard() {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 2.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2), // Black border added
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.black),
            const SizedBox(width: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name",style: TextStyle(fontWeight: FontWeight.w600),),
                Text(
                  
                  _userName,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 16.0,
                  
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // General info card for displaying email or other account details
  Widget buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2), // Black border added
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
