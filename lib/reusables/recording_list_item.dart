import 'package:flutter/material.dart';
import 'package:vear/services/database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vear/objects/recording.dart';
import 'package:vear/screens/profile_screen.dart';
import 'package:flutter_tags/tag.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vear/screens/player_screen.dart';

class RecordingListItem extends StatefulWidget {
  final String creatorId;
  final String currentUserId;
  final Recording recording;

  RecordingListItem(this.creatorId, this.currentUserId, this.recording);

  @override
  State<StatefulWidget> createState() {
    return _RecordingListItemState();
  }
}

class _RecordingListItemState extends State<RecordingListItem> {
  Database _database = Database();
  dynamic user;

  String currentUserLiked = "";
  int likes = 0;
  int disLikes = 0;

  void submitLikeOrDislike(bool liked) async {
    await _database.likeOrDislikeRecording(liked, widget.creatorId, widget.currentUserId,
        widget.recording.recordingTitle).then((value) async {
          setState(() {
            getRecordingLikes();
          });
    }).catchError((error){
      print("Error adding new like or dislike: $error");
    });
  }

  void getRecordingLikes() async {
    await _database.getRecordingLikes(widget.recording.recordingTitle).then((value){
      int recordingLikes = 0;
      int recordingDisLikes = 0;

      if (value != null) {
        (value).forEach((k,v){
          if (v["liked"] == "like"){
            recordingLikes++;
          } else {
            recordingDisLikes++;
          }

          if (v["likerId"] == widget.currentUserId) {
            currentUserLiked = v["liked"];
          }
        });
      }

      setState(() {
        likes = recordingLikes;
        disLikes = recordingDisLikes;
      });

    }).catchError((error){
      print("Error getting likes for recording: $error");
    });
  }

  void getTileUser() async {
    await _database.getUser(widget.creatorId).then((value) {
      if (value != null) {
        setState(() {
          user = value;
        });
      } else {
        print("Error getting user for list tile");
      }
    }).catchError((error) {
      print("Error getting user for list tile: $error");
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Full Description:",
            style: GoogleFonts.ubuntu(
                textStyle: TextStyle(fontStyle: FontStyle.normal)),
          ),
          content: Text(
            widget.recording.recordingDescription,
            style: GoogleFonts.ubuntu(
                textStyle:
                    TextStyle(fontSize: 14.0, fontStyle: FontStyle.normal)),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Close",
                style: GoogleFonts.ubuntu(
                    textStyle: TextStyle(
                        color: const Color(0xFF679436),
                        fontStyle: FontStyle.normal)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getTileUser();
    setState(() {
      getRecordingLikes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        height: 212,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: const Color(0xFFEEF5DB),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10.0),
                  height: 90.0,
                  width: 90.0,
                  decoration: BoxDecoration(
                    //shape: BoxShape.circle,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: new NetworkImage(
                        widget.recording.recordingImage,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin:
                            EdgeInsets.only(left: 8.0, top: 27.0, bottom: 8.0),
                        width: 220.0,
                        child: Text(
                          widget.recording.recordingTitle,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(
                              textStyle: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF679436))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8.0),
                        width: 220.0,
                        child: Text(
                          "Description",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(
                              textStyle: TextStyle(
                                  fontSize: 10.0, fontStyle: FontStyle.italic)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8.0),
                        width: 220.0,
                        child: Text(
                          widget.recording.recordingDescription,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(
                              textStyle: TextStyle(fontSize: 12.0)),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(
                            left: 8.0,
                          ),
                          width: 220.0,
                          child: GestureDetector(
                            child: Text(
                              "View More...",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.ubuntu(
                                  textStyle: TextStyle(
                                      fontSize: 10.0,
                                      fontStyle: FontStyle.italic)),
                            ),
                            onTap: () {
                              _showDialog();
                            },
                          )),
                      Container(
                          margin: EdgeInsets.only(left: 8.0, top: 5.0),
                          width: 220.0,
                          child: GestureDetector(
                            child: Text(
                              user != null
                                  ? "By: ${user["full_name"]}"
                                  : "Loading info...",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.ubuntu(
                                  textStyle: TextStyle(
                                      fontSize: 10.0,
                                      fontStyle: FontStyle.normal)),
                            ),
                            onTap: () {
                              //TODO ~ Open user profile
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ProfileScreen(user, widget.currentUserId)));
                            },
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Tags(
                                itemCount: widget.recording.tags.length,
                                itemBuilder: (int index) {
                                  return ItemTags(
                                    index: index,
                                    title: widget.recording.tags[index],
                                    activeColor: const Color(0xFF679436),
                                    textColor: Colors.black,
                                    textActiveColor: Colors.black,
                                  );
                                }),
                          ))
                    ],
                  ),
                ),
                Container(
                    child: GestureDetector(
                  child: Icon(
                    Icons.headset,
                    color: const Color(0xFF679436),
                    size: 50.0,
                  ),
                  onTap: () {
                    //TODO ~ bring to player screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PlayerScreen(widget.recording, widget.creatorId, widget.currentUserId)));
                  },
                )),
              ],
            ),
            Divider(),
            Container(
              margin: EdgeInsets.only(right: 10.0, left: 10.0),
              child: Row(
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        setState(() {
                          submitLikeOrDislike(true);
                        });
                      },
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 5.0, right: 5.0),
                              child: Text(likes.toString()),
                            ),
                            Icon(Icons.thumb_up, color: currentUserLiked == "like" ? const Color(0xFF679436): Colors.black45,),
                          ],
                        ),
                      )
                  ),
                  FlatButton(
                      onPressed: (){
                        setState(() {
                          submitLikeOrDislike(false);
                        });
                      },
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 5.0, right: 5.0),
                              child: Text(disLikes.toString()),
                            ),
                            Icon(Icons.thumb_down, color: currentUserLiked == "dislike" ? const Color(0xFF679436): Colors.black45,),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
