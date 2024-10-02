import 'package:taskmaster/user/user_home.dart';
import 'package:taskmaster/user/user_toDo.dart';
import 'package:taskmaster/user/user_profile.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late DashboardScreen homepage;
  late ProfileScreen profile;
  late ToDoPage toDo;

  @override
  void initState() {
    homepage = DashboardScreen();
    toDo = ToDoPage();
    profile = ProfileScreen();

    pages = [homepage, toDo, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: currentTabIndex,
        backgroundColor: Colors.black,
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home_outlined),
            title: Text("Home"),
            selectedColor: Colors.blue,
            unselectedColor: Colors.white,
          ),

          /// ToDo
          SalomonBottomBarItem(
            icon: Icon(Icons.add),
            title: Text("ToDo"),
            selectedColor: Colors.orange,
            unselectedColor: Colors.white,

          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person_outline),
            title: Text("Profile"),
            selectedColor: Colors.green,
            unselectedColor: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: pages[currentTabIndex],
      ),
    );
  }
}
