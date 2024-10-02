import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaster/Authentication/onboarding.dart';
import 'package:taskmaster/Authentication/welcome.dart';
import 'package:taskmaster/admin/admin_bottomnav.dart';
import 'package:taskmaster/database/shared_pref.dart';
import 'package:taskmaster/user/user_bottomnav.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Duration of the splash screen animation
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));

    _controller!.forward();

    // Check login status after a delay
    Future.delayed(Duration(seconds: 3), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    bool isAdminLoggedIn = await SharedPreferenceHelper.isAdminLoggedIn();
    bool isLoggedIn = await SharedPreferenceHelper.isLoggedIn();

    if (isAdminLoggedIn) {
      _navigateToAdminHome();
    } else if (isLoggedIn) {
      _navigateToUserHome();
    } else {
      _navigateToWelcome();
    }
  }

  void _navigateToAdminHome() {
    Get.offAll(() => AdminBottomNav());
  }

  void _navigateToUserHome() {
    Get.offAll(() => BottomNav());
  }

  void _navigateToWelcome() {
    Get.offAll(() => WelcomeScreen());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired background color
      body: Center(
        child: FadeTransition(
          opacity: _animation!,
          child: Image.asset(
            'assets/images/splash_logo.png', // Path to your image asset
            width: 250, // Set the width of the logo
            height: 250, // Set the height of the logo
          ),
        ),
      ),
    );
  }
}
