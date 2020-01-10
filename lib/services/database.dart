import 'package:firebase_database/firebase_database.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:vear/objects/recording.dart';
import 'package:event_bus/event_bus.dart';
import 'package:vear/objects/loading_event.dart';

class Database {
  EventBus eventBus = EventBus();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  //Get a global variable of todays date
  String todaysDate = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);

  //TODO ~ GET USER
  Future<dynamic> getUser(String userId) async{
    return await _databaseReference.child("users").child(userId).once().then((DataSnapshot snapshot){
      if (snapshot.value != null) {
        return snapshot.value;
      }else {
        //No given user in DB 🤷
        return null;
      }
    }).catchError((error){
      print(error);
    });
  }

  //TODO ~ Add user to DB
  Future<dynamic> addNewUser(String userId, Map<dynamic,dynamic> userValues) async{
    return await _databaseReference.child("users").child(userId).set(userValues).then((value) async {
      return await getUser(userId).then((value){
        return value;
      });
    }).catchError((error){
      print("Error adding new user node to DB: $error");
    });
  }

  //TODO ~ REMOVE USER
  Future<void> removeUserFromDB(String userId) async {
    await _databaseReference.child("users").child(userId).remove().then((value) {
      //Nothing to do here...
    }).catchError((error) {
      print("Error removing user node from DB: $error");
    });
  }

  //TODO ~ Update user values
  Future updateUserValue(String userId, Map<String, dynamic> newValues) async {
    await _databaseReference.child("users").child(userId).update(newValues).then((value){

    }).catchError((error){
      print("Error adding new user values $error");
    });
  }

  //TODO ~ Add recording to user
  Future<void> addRecording(String uid, Map<String, dynamic> recordingProperties) async {
    //Add the recording to the user specific node...
    await _databaseReference.child("users").child(uid).child("recordings").push().set(recordingProperties).then((value) async {
      //Add this new recording to the mass group of recordings as well!
      await _databaseReference.child("allRecordings").push().set(recordingProperties);
    }).catchError((error){
      print("Error adding new user recording $error");
    });
  }


  //TODO ~ GET ALL RECORDINGS... (maybe sorted?)
  Future<List<Recording>> getRecordings([String keyword]) async {
    eventBus.fire(LoadingEvent(true));
    List<Recording> recordings = [];

    return await _databaseReference.child("allRecordings").once().then((DataSnapshot snapshot){
      if (snapshot.value != null) {
        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          if (keyword != null) {
            //User is searching by keyword... We need to loop through the tags on a recording and only return the recordings that have the keyword as a tag
            //First check if a recording even has tags
            if (value["tags"] != null) {
              print(value["tags"]);
              if ((value["tags"] as List<dynamic>).contains(keyword)) {
                recordings.add(Recording.fromJson(value));
              }
            }
          } else {
            recordings.add(Recording.fromJson(value));
          }
        });
        eventBus.fire(LoadingEvent(false));
        return recordings;
      }else {
        //No given user in DB 🤷
        eventBus.fire(LoadingEvent(false));
        return recordings;
      }
    }).catchError((error){
      print("Error adding new user values $error");
    });
  }

  Future<void> likeOrDislikeRecording(bool liked, String creatorId, String likerId, String recordingTitle) async {
      await _databaseReference.child("allRecordings").once().then((DataSnapshot snapshot){
        if (snapshot.value != null) {
          (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
            if (value["recordingTitle"] == recordingTitle) {
              _databaseReference.child("allRecordings").child(key).child("likes").child(likerId).update({"likerId": likerId, "liked": liked ? "like" : "dislike"});
            }
          });
        }
      }).catchError((error){
        print("Error adding like to allRecordings node in DB: $error");
      });

      await _databaseReference.child("users").child(creatorId).child("recordings").once().then((DataSnapshot snapshot){
        if (snapshot.value != null) {
          (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
            if (value["recordingTitle"] == recordingTitle) {
              _databaseReference.child("users").child(creatorId).child("recordings").child(key).child("likes").child(likerId).update({"likerId": likerId, "liked": liked ? "like" : "dislike"});
            }
          });
        }
      }).catchError((error){
        print("Error adding like to specific user recording node in DB: $error");
      });

  }

  Future<Map<dynamic, dynamic>> getRecordingLikes(String recordingTitle) async {
    Map<dynamic, dynamic> likes;
    return await _databaseReference.child("allRecordings").once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) async  {
          if (value["recordingTitle"] == recordingTitle) {
            likes = value["likes"];
          }
        });
        return likes;
      } else {
        return likes;
      }

      //return likes;
    }).catchError((error){
      print("Error getting recording likes: $error");
    });
  }

  Future<void> followUser(String id, String userToFollow) async {
    await  _databaseReference.child("users").child(userToFollow).child("followers").child(id).update({"following": true});
    await  _databaseReference.child("users").child(id).child("following").child(userToFollow).update({"following": true});
  }

  Future<void> unFollowUser(String id, String followId) async {
    await  _databaseReference.child("users").child(followId).child("followers").child(id).remove();
    await  _databaseReference.child("users").child(id).child("following").child(followId).remove();
  }

  Future<bool> isFollowing(String id, String followId) async {
    return await _databaseReference.child("users").child(followId).child("followers").child(id).once().then((DataSnapshot snapshot){
      if (snapshot.value != null) {
        return true;
      } else {
        return false;
      }
    }).catchError((error){
      print("Error checking following status: $error");
    });
  }

  Future<Map<dynamic, dynamic>> getFollowers(String id) async {
    return await _databaseReference.child("users").child(id).child("followers").once().then((DataSnapshot snapshot){
      return snapshot.value;
    }).catchError((error){
      print("Error getting user followers");
    });
  }
}