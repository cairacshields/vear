import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vear/services/storage.dart';
import 'package:vear/services/database.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:async';
import 'dart:io';

class TopSectionProfile extends StatefulWidget {
  final dynamic user;
  final String viewingUserId;

  TopSectionProfile(this.user, this.viewingUserId);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TopSectionProfileState();
  }
}
class _TopSectionProfileState extends State<TopSectionProfile> {
  Database _database = Database();
  Storage _storage = Storage();
  File _image;
  PaletteGenerator _paletteGenerator;

  Color bodyColor;
  Color titleColor;
  Color backgroundColor;

  //boolean to manage whether the currently logged in user is viewing their own profile or someone else's
  //Will be true if they are viewing their own
  bool _isSameUser;

  bool _alreadyFollowing;

  String followerCount;
  String followingCount;
  String recordingsCount;

  void isCurentUserViewing() {
    setState(() {
      _isSameUser = widget.user["id"] == widget.viewingUserId;
    });
  }

  void setUserCounts() {
    if (widget.user["followers"] != null) {
      followerCount = (widget.user["followers"] as Map<dynamic, dynamic>).length.toString();
    } else {
      followerCount = "0";
    }

    if (widget.user["following"] != null) {
      followingCount = (widget.user["following"] as Map<dynamic, dynamic>).length.toString();
    } else {
      followingCount = "0";
    }

    if (widget.user["recordings"] != null) {
      recordingsCount = (widget.user["recordings"] as Map<dynamic, dynamic>).length.toString();
    } else {
      recordingsCount = "0";
    }
  }

  void unFollow() async {
    await _database.unFollowUser(widget.viewingUserId, widget.user["id"]);
  }

  void follow() async {
    await _database.followUser(widget.viewingUserId, widget.user["id"]);
  }

  void getFollowingStatus() async {
    await _database.isFollowing(widget.viewingUserId, widget.user["id"]).then((value){
      setState(() {
        _alreadyFollowing = value;
      });
    }).catchError((error){
      print("Error following user: $error");
    });
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) async {
        await _storage.uploadProfilePicture(widget.user["id"], image).then((value){
          if (value != null) {
            setState(() {
              _image = image;
              getUserProfileImage();
            });
          }
        }).catchError((error){
          print("Error opening image picker: $error");
        });
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isCurentUserViewing();
    getFollowingStatus();
    setUserCounts();
    getPalette(getUserProfileImage());
  }

  NetworkImage getUserProfileImage() {
    return new NetworkImage(
      widget.user["profile_pic_url"] != null ? widget.user["profile_pic_url"] :
      "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQMgRbNQhU19ONiJK71H22tB8ItBNqMkqxGyEBM3hyFq1Cqqlqf",

    );
  }

  void getPalette(NetworkImage paletteImage) {
    PaletteGenerator.fromImageProvider(paletteImage).then((value){
      setState(() {
        _paletteGenerator = value;

        bodyColor = _paletteGenerator.vibrantColor.bodyTextColor != null ? _paletteGenerator.vibrantColor.bodyTextColor: Colors.black;
        titleColor =  _paletteGenerator.vibrantColor.titleTextColor != null ? _paletteGenerator.vibrantColor.titleTextColor: Colors.black;
        backgroundColor = _paletteGenerator.vibrantColor.color != null ? _paletteGenerator.vibrantColor.color: Colors.black26;
      });
    }).catchError((error){
      print("Error grabbing Palette from image provided: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor != null ? backgroundColor : Colors.grey,
      height: 360.0,
      width: MediaQuery.of(context).size.width,
      child: Container(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    height: 100.0,
                    width: 100.0,
                    margin: EdgeInsets.only(top: 40.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: getUserProfileImage(),
                      )
                    ),
                  ),
                  onTap: () async {
                    //Should open image picker
                    await chooseFile();
                  },
                ),
                _isSameUser ? Container(
                  margin: EdgeInsets.only(top: 110.0, right: 50.0),
                  child: Icon(
                    Icons.edit,
                    color: const Color(0xFF679436),
                  ),
                ) : SizedBox()
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 15.0),
              child: Text(
                widget.user["full_name"],
                style: GoogleFonts.ubuntu(textStyle: TextStyle(fontSize: 35.0, color: titleColor != null ? titleColor : Colors.black)),
              ),
            ),
            Container(
              height: 100.0,
              margin: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.person_add,
                              color: const Color(0xFF679436),
                            ),
                            Text(
                              "Followers",
                              style: GoogleFonts.ubuntu(
                                  textStyle: TextStyle(fontSize: 20.0,
                                      color:  bodyColor != null ? bodyColor: Colors.black))
                              ,
                            ),
                            Text(
                              followerCount,
                              style: GoogleFonts.ubuntu(
                                  textStyle: TextStyle(fontSize: 15.0,
                                      color:  bodyColor != null ? bodyColor: Colors.black)),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.all_inclusive,
                            color: const Color(0xFF679436),
                          ),
                          Text(
                            "Following",
                            style: GoogleFonts.ubuntu(
                                textStyle: TextStyle(fontSize: 20.0,
                                    color: bodyColor != null ? bodyColor: Colors.black)),
                          ),
                          Text(
                            followingCount,
                            style: GoogleFonts.ubuntu(
                                textStyle: TextStyle(fontSize: 15.0,
                                    color:  bodyColor != null ? bodyColor: Colors.black)),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.record_voice_over,
                            color: const Color(0xFF679436),
                          ),
                          Text(
                            "Posts",
                            style: GoogleFonts.ubuntu(
                                textStyle: TextStyle(fontSize: 20.0,
                                    color: bodyColor != null ? bodyColor : Colors.black)),
                          ),
                          Text(
                            recordingsCount,
                            style: GoogleFonts.ubuntu(
                                textStyle: TextStyle(fontSize: 15.0,
                                    color: bodyColor != null ? bodyColor: Colors.black)),
                          )
                        ],
                      ),
                    ),
                  ])),
            ),

            _isSameUser ? SizedBox() : Container(
              child: Center(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: const Color(0xFF679436))),
                  onPressed: () async {
                    setState(() {
                      if (_alreadyFollowing) {
                        unFollow();
                      } else {
                        follow();
                      }
                      getFollowingStatus();
                    });
                  },
                  color: _alreadyFollowing ? Colors.black26 : const Color(0xFF679436),
                  textColor: Colors.white,
                  child: Text( _alreadyFollowing ? "Unfollow".toUpperCase() : "Follow".toUpperCase(),
                      style: TextStyle(fontSize: 14)),
                ),
              )
            )

          ],
        ),
      ),
    );
  }
}
