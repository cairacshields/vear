/*
*
* ~~~ VEAR ~~~
* The mobile application designed to unite people through spoken words
*
*
* App colors ️‍🌈
* #A5BE00
* #EEF5DB
* #679436
*
* */

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vear',
        home: SplashScreen(),
        routes: <String, WidgetBuilder>{
          '/login': (BuildContext context) => LoginScreen(),
          '/register': (BuildContext context) => RegisterScreen(),
        });
  }
}
