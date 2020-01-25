import 'package:flutter/material.dart';
import 'package:vear/reusables/profile_top.dart';
import 'package:vear/objects/recording.dart';
import 'package:vear/reusables/recording_list_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vear/services/auth.dart';
import 'package:vear/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final dynamic user;
  final String viewingUserId;

  ProfileScreen(this.user, this.viewingUserId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthService _authService = AuthService();
  List<Recording> _userRecordings = [];

  void  unpackRecordings() {
    if (widget.user["recordings"] != null) {
      (widget.user["recordings"] as Map<dynamic, dynamic>).forEach((k,v){
        _userRecordings.add(Recording.fromJson(v));
      });
    }
  }

  Widget getUserRecordingList() {
    return _userRecordings.length > 0 ?
        Container(
          child: SingleChildScrollView(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                shrinkWrap: true,
                physics: new ClampingScrollPhysics(),
                //scrollDirection: Axis.horizontal,
                itemCount: _userRecordings.length,
                itemBuilder: (BuildContext context, int index) {
                  var recording = _userRecordings[index];
                  return RecordingListItem(recording.creatorId, widget.viewingUserId, recording);
                },
              ),
            ),
          ),
        ): Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/6),
          child: Center(
            child: Text("User has no recordings.", style: GoogleFonts.ubuntu(
            textStyle: TextStyle(
            fontSize: 20.0,
                fontStyle: FontStyle.normal)),),
          ),
        );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    unpackRecordings();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.all(10.0),
            child: GestureDetector(
              child: Icon(Icons.exit_to_app),
              onTap: () async {
                //Should sign out user
                await _authService.signOutUser().then((value){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              LoginScreen()));
                }).catchError((error){
                  print("Error signing out user... : $error");
                });
              },
            ),
          )
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TopSectionProfile(widget.user, widget.viewingUserId),
              getUserRecordingList()
            ],
          ),
        ),
      ),
    );
  }
}