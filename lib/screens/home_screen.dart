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
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
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
    await _authService.currentUser.then((value) {
      setState(() {
        currentUser = value;
      });
    }).catchError((error) {
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

  void _onRefresh() async {
    getRecordings();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  Widget recordingsList() {
    return Flexible(child: SmartRefresher(
      scrollDirection: Axis.vertical,
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("Pull up load");
          } else if (mode == LoadStatus.loading) {
            body = CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed! Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("Release to load more");
          } else {
            body = Text("No more Data");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: _loading
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
                      Text(
                        "No recordings posted yet.",
                        style: GoogleFonts.ubuntu(
                            textStyle: TextStyle(fontSize: 20.0)),
                      ),
                      Icon(
                        Icons.trending_down,
                        color: const Color(0xFF679436),
                        size: 150.0,
                      )
                    ],
                  )),
                )
              : MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    //scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recordings.length,
                    itemBuilder: (BuildContext context, int index) {
                      var recording = recordings[index];
                      return RecordingListItem(
                          recording.creatorId, currentUser.uid, recording);
                    },
                  ),
                ),
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
          height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          Header(widget.user, currentUser),
          SearchBar(widget.user, updateSearchQuery),
          recordingsList(),
        ],
      ),
    ));
  }
}
