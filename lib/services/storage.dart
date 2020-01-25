import 'package:firebase_storage/firebase_storage.dart';
import 'database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'package:path/path.dart' as Path;
import 'dart:async';
import 'dart:io';
import 'package:event_bus/event_bus.dart';
import 'package:vear/objects/loading_event.dart';

class Storage {
  EventBus eventBus = EventBus();
  Database _database = Database();
  final StorageReference _storageReference = FirebaseStorage.instance
      .ref();

  //TODO ~ UPLOAD PROFILE IMAGE
  Future<String> uploadProfilePicture(String userId, File image) async {
    String downloadUrl;

    StorageUploadTask uploadTask = _storageReference.child("${userId}/profilePic").putFile(image);
    await uploadTask.onComplete;
    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    downloadUrl = downUrl.toString();

    await _database.updateUserValue(userId, {"profile_pic_url": downloadUrl});
    return downloadUrl;
  }

  //TODO ~ Upload Recording image
  Future<String> uploadRecordingPicture(String userId,  String recordingTitle, File recordingImage) async {
    String downloadUrl;

    StorageUploadTask uploadTask = _storageReference.child("${userId}/recordings/${recordingTitle}/image").putFile(recordingImage);
    await uploadTask.onComplete;
    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    downloadUrl = downUrl.toString();

    return downloadUrl;
  }

  //TODO ~ UPLOAD new user recording
  Future<String> uploadUserRecording(String userId, String recordingTitle,
      String recordingDescription, List<String> tags, File recordingImage, File recording) async {
    eventBus.fire(LoadingEvent(true));
    String downloadUrl;
    String imageUrl;

    StorageUploadTask uploadTask = _storageReference.child("${userId}/recordings/${recordingTitle}").putFile(recording);
    await uploadTask.onComplete;
    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    downloadUrl = downUrl.toString();

    //Upload the recording image
    await uploadRecordingPicture(userId, recordingTitle, recordingImage).then((value){
      if (value != null) {
        imageUrl = value;
      }
    }).catchError((error){
      print("Error uploading recording image");
    });

    await _database.addRecording(userId, {"creatorId": userId, "recordingTitle": recordingTitle,
      "recordingDescription": recordingDescription, "tags": tags, "recordingImage": imageUrl, "recordingUrl": downloadUrl});
    eventBus.fire(LoadingEvent(false));
    return downloadUrl;
  }

  //TODO ~ Remove a particular recording and it's image
  Future<void> removeRecordingFromDB(String userId, String recordingTitle) async {
    await _storageReference.child("${userId}/profilePic").delete();
    await _storageReference.child("${userId}/recordings/${recordingTitle}/image").delete();
  }
}