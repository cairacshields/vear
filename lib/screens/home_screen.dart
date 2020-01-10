import 'package:flutter/material.dart';
import 'package:vear/reusables/header.dart';
import 'package:vear/reusables/search_bar.dart';
import 'package:vear/services/database.dart';
import 'package:vear/objects/recording.dart';
import 'package:event_bus/event_bus.dart';
import 'package:vear/reusables/recording_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vear/services/auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final dynamic user;

  HomeScreen(this.user);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  AuthService _authService = AuthService();
  Database _database = Database();
  List<Recording> recordings = [];

  bool _loading = false;
  String _searchQuery;
  FirebaseUser currentUser;

  String currentUserLiked = "";

  void setUpLoadingListener() {
    EventBus eventBus = _database.eventBus;
    eventBus.on<LoadingEvent>().listen((event) {
      // All events are of type UserLoggedInEvent (or subtypes of it).
      setState(() {
        _loading = event.isLoading;
      });
    });
  }

  void getCurrentUser() async {
    await _authService.currentUser.then((value){
      setState(() {
        currentUser = value;
      });
    }).catchError((error){
      print("Error getting currently logged in user: $error");
    });
  }

  void getRecordings() async {
    _searchQuery != null
        ? await _database.getRecordings(_searchQuery).then((value) {
            print(_searchQuery);
            setState(() {
              recordings = value;
            });
          }).catchError((error) {
            print("Error getting recordings from database: $error");
          })
        : await _database.getRecordings().then((value) {
            setState(() {
              recordings = value;
            });
          }).catchError((error) {
            print("Error getting recordings from database: $error");
          });
  }

  void updateSearchQuery([String newQuery]) {
    setState(() {
      _searchQuery = newQuery;
      getRecordings();
    });
  }

  Widget recordingsList() {
    return _loading
        ? Container(
            margin: EdgeInsets.only(top: 100.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : recordings.length <= 0
            ? Container(
                margin: EdgeInsets.only(top: 100.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text("No recordings posted yet.", style: GoogleFonts.ubuntu( textStyle: TextStyle(fontSize: 20.0)),),
                      Icon(Icons.trending_down, color: const Color(0xFF679436), size: 150.0,)
                    ],
                  )
                ),
              )
            : MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  //scrollDirection: Axis.horizontal,
                  itemCount: recordings.length,
                  itemBuilder: (BuildContext context, int index) {
                    var recording = recordings[index];
                    return RecordingListItem(recording.creatorId, currentUser.uid, recording);
                  },
                ),
              );
  }

  @override
  void initState() {
    super.initState();
    getRecordings();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Header(widget.user),
            SearchBar(widget.user, updateSearchQuery),
//            Expanded(
//                child:
            recordingsList()
            // ),
          ],
        ),
      ),
    ));
  }
}
