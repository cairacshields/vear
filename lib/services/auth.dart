import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database.dart';
import 'package:event_bus/event_bus.dart';

class LoadingEvent {
  bool isLoading;
  LoadingEvent(this.isLoading);
}

class AuthService {
  //Get an instance of the Firebase Auth service
  EventBus eventBus = EventBus();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Database _database = Database();

  Future<FirebaseUser> get currentUser async{
    return _auth.currentUser().then((value){
      return value;
    }).catchError((error){
      return null;
    });
  }

  //TODO CREATE LOGIN FUNCTIONALITY
  Future login(String emailAddress, String password) async {
    eventBus.fire(LoadingEvent(true));
    return await _auth.signInWithEmailAndPassword(email: emailAddress, password: password)
        .then((value) async {
      return await _database.getUser(value.user.uid).then((value){
        eventBus.fire(LoadingEvent(false));
        return value;
      });
    }).catchError((error) {
      print("No user found");
      eventBus.fire(LoadingEvent(false));
      return null;
    });
  }

  //TODO ~ CREATE SIGNUP FUNCTIONALITY
  Future signUp(String emailAddress, String password, Map<dynamic, dynamic> userExtras) async {
    eventBus.fire(LoadingEvent(true));
    return await _auth.createUserWithEmailAndPassword(email: emailAddress, password: password)
        .then((value) async {
      userExtras.addAll({"id": value.user.uid, "email": value.user.email});
      eventBus.fire(LoadingEvent(false));
      return await _database.addNewUser(value.user.uid, userExtras);
    }).catchError((error) {
      print("Unable to create new user: $error");
      eventBus.fire(LoadingEvent(false));
      return null;
    });
  }

  //TODO SIGN OUT FUNCTIONALITY
  Future<bool> signOutUser() async {
    return await _auth.signOut()
        .then((value) {
      print("Signed out successfully");
      return true;
    })
    .catchError((error) {
      print("Error signing user out: ${error.toString()}");
      return false;
    });
  }
}