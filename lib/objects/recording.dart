import 'package:flutter/material.dart';

class Recording {
  String creatorId;
  String recordingDescription;
  String recordingTitle;
  String recordingUrl;
  String recordingImage;
  List<dynamic> tags;
  Map<dynamic, dynamic> likes;
  Map<dynamic, dynamic> disLikes;


  Recording(
      {this.creatorId,
      this.recordingTitle,
      this.recordingDescription,
      this.recordingUrl,
      this.recordingImage,
      this.tags,
      this.likes,
      this.disLikes});

  factory Recording.fromJson(Map<dynamic, dynamic> json) {
    return Recording(
        creatorId: json['creatorId'],
        recordingTitle: json['recordingTitle'],
        recordingDescription: json['recordingDescription'],
        recordingUrl: json['recordingUrl'],
        recordingImage: json['recordingImage'],
        tags: json['tags'],
        likes: json['likes'],
        disLikes: json['disLikes']);
  }
}
