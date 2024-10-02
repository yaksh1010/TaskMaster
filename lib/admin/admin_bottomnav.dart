import 'package:taskmaster/admin/admin_addTask.dart';
import 'package:taskmaster/admin/admin_completedTasks.dart';
import 'package:taskmaster/admin/admin_profile.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:taskmaster/admin/admin_order.dart';
import 'package:taskmaster/admin/admin_home.dart';
import 'package:flutter/material.dart';

class AdminBottomNav extends StatefulWidget {
  const AdminBottomNav({super.key});

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late AdminHome adminHome;
  late AdminProfileScreen profile;
  late AddTask addTask;

  @override
  void initState() {
    adminHome = const AdminHome();
    addTask =  const AddTask();
    profile = const AdminProfileScreen();

    pages = [adminHome, addTask, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[currentTabIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SalomonBottomBar(
          currentIndex: currentTabIndex,
          onTap: (index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: [
            /// Home
            SalomonBottomBarItem(
              icon: const Icon(Icons.home_outlined),
              title: const Text("Home"),
              unselectedColor: Colors.white,
              selectedColor: Colors.purple,
            ),

            /// Completed Tasks
            SalomonBottomBarItem(
              icon: const Icon(Icons.add),
              title: const Text("Add Tasks"),
              selectedColor: Colors.orange,
              unselectedColor: Colors.white,
            ),

            /// Profile
            SalomonBottomBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              title: const Text("Profile"),
              selectedColor: Colors.teal,
              unselectedColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
