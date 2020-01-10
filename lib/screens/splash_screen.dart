import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vear/services/database.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Database _database = Database();

  @override
  initState() {
    Future.delayed(const Duration(milliseconds: 5000), () {
      FirebaseAuth.instance
          .currentUser()
          .then((currentUser) async {
        if (currentUser == null){
          Navigator.pushReplacementNamed(context, "/login");
        } else {
          //TODO ~ Get the user from DB and pass to home screen
          await _database.getUser(currentUser.uid)
              .then((value){
            if (value != null) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(
                          value
                      )));
            } else {
              //No user found in DB
              Navigator.pushReplacementNamed(context, "/login");
            }
          }).catchError((error){
            print("Error retrieving user from database: $error");
          });
        }
      })
      .catchError((err) => print(err));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: const Color(0xFFA5BE00),
          child: Container(
            alignment: AlignmentDirectional.center,
            margin: EdgeInsets.only(top: 20.0),
            child: Image.asset(
              'assets/images/icon.png',
              height: 200.0,
              width: 150.0,
            ),
          ),
        ),
      ),
    );
  }
}