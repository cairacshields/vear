import 'package:flutter/material.dart';
import 'package:vear/custom/green_paint.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vear/services/auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:event_bus/event_bus.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  // Create some text controllers. Later, use them to retrieve the
  // current value of the TextFields.
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  Future<dynamic> completeRegistration(
      String email, String password, Map<dynamic, dynamic> userExtras) async {
    return await _authService.signUp(email, password, userExtras).then((value) {
      return value;
    }).catchError((error) {
      return null;
    });
  }

  void setUpLoadingListener() {
    EventBus eventBus = _authService.eventBus;
    eventBus.on<LoadingEvent>().listen((event) {
      // All events are of type UserLoggedInEvent (or subtypes of it).
      setState(() {
        _loading = event.isLoading;
      });
    });
  }

  final registerError = SnackBar(
    content: Text("Error completing registration, please try again."),
  );

  final generalErrorSnackBar =
      SnackBar(content: Text("An error occured. Please try again."));

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the
    // widget tree.
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpLoadingListener();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        body: CustomPaint(
      size: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      painter: GreenPaint(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 200.0, bottom: 40.0),
                  child: Text(
                    "Join Vear",
                    style: GoogleFonts.ubuntu(fontSize: 40.0),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: nameController,
                    cursorColor: const Color(0xFF679436),
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(color: const Color(0xFF679436)),
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: const Color(0xFF679436)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: const Color(0xFF679436)),
                      ),
                    ),
                    validator: (val) {
                      if (val.length == 0) {
                        return "Name cannot be empty";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.ubuntu(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: emailController,
                    cursorColor: const Color(0xFF679436),
                    decoration: InputDecoration(
                      labelText: "Enter Email",
                      labelStyle: TextStyle(color: const Color(0xFF679436)),
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: const Color(0xFF679436)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: const Color(0xFF679436)),
                      ),
                    ),
                    validator: (val) {
                      if (val.length == 0) {
                        return "Email cannot be empty";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.ubuntu(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    cursorColor: const Color(0xFF679436),
                    decoration: InputDecoration(
                      labelText: "Enter Password",
                      labelStyle: TextStyle(color: const Color(0xFF679436)),
                      focusColor: const Color(0xFF679436),
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: const Color(0xFF679436)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: const Color(0xFF679436)),
                      ),
                    ),
                    validator: (val) {
                      if (val.length <= 5) {
                        return "Password must be longer than 5";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
                    style: GoogleFonts.ubuntu(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: passwordConfirmController,
                    obscureText: true,
                    cursorColor: const Color(0xFF679436),
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      labelStyle: TextStyle(color: const Color(0xFF679436)),
                      focusColor: const Color(0xFF679436),
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: const Color(0xFF679436)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: const Color(0xFF679436)),
                      ),
                    ),
                    validator: (val) {
                      if (passwordController.text !=
                          passwordConfirmController.text) {
                        return "Password do not match";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
                    style: GoogleFonts.ubuntu(),
                  ),
                ),
                Container(
                  child: _loading
                      ? CircularProgressIndicator()
                      : Column(
                          children: <Widget>[
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(
                                      color: const Color(0xFF679436))),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  await completeRegistration(
                                          emailController.text,
                                          passwordController.text,
                                          {"full_name": nameController.text})
                                      .then((returnVal) async {
                                    if (returnVal == null) {
                                      print(
                                          "Value from attempting to register: $returnVal");
                                      _scaffoldKey.currentState.showSnackBar(registerError);
                                    } else {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  HomeScreen((returnVal))));
                                    }
                                  }).catchError((error) {
                                    print(
                                        "Error occured while attempting to register user: $error");
                                    _scaffoldKey.currentState.showSnackBar(generalErrorSnackBar);
                                  });
                                }
                              },
                              color: const Color(0xFF679436),
                              textColor: Colors.white,
                              child: Text("Sign up".toUpperCase(),
                                  style: TextStyle(fontSize: 14)),
                            ),
                            Container(
                              child: GestureDetector(
                                child: Text(
                                  "Already have an account?",
                                  style: GoogleFonts.ubuntu(),
                                ),
                                onTap: () {
                                  //Take to registration page
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              LoginScreen()));
                                },
                              ),
                            )
                          ],
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
