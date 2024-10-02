// import "package:taskmaster/admin/admin_bottomnav.dart";
// import "package:taskmaster/admin/admin_login.dart";
// import "package:taskmaster/authentication/login_screen.dart";
import "package:flutter/material.dart";
import "package:taskmaster/Authentication/login_screen.dart";
import "package:taskmaster/admin/admin_login.dart";
import "package:taskmaster/constants/colors.dart";
import "package:taskmaster/user/user_bottomnav.dart";

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),

          //column
          child: Padding(
            padding: EdgeInsets.only(top: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              
              children: [
                //Section 1
                const Image(image: AssetImage("assets/images/Welcome.gif"), width: 300, height: 300),
                //sectin 2
            
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Welcome New User!",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 20,),
                const Align(
                    alignment: Alignment.center,
                    child: Text("To assign Task with Ease, \n Task Master is the Key!!!",
                        style: TextStyle(fontSize: 20))),
                const SizedBox(
                  height: 70,
                ),
                //section 3
                Column(children: [
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLogin()));
                      },
                      child: const Text(
                        "ADMIN",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //Signup Button
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CCcolors.primary,
                          foregroundColor: Color.fromARGB(255, 0, 0, 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      child: const Text(
                        "USER",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
