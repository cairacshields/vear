import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vear/screens/profile_screen.dart';
import 'package:vear/screens/recording_screen.dart';

class SearchBar extends StatefulWidget {
  final dynamic user;
  final Function updateSearchQuery;

  SearchBar(this.user, this.updateSearchQuery);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchBarState();
  }
}

class _SearchBarState extends State<SearchBar> {
  final searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Widget getSearchBar() {
    return Container(
        margin: EdgeInsets.only(top: 25.0, right: 10.0, left: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                cursorColor: const Color(0xFF679436),
                decoration: InputDecoration(
                  labelText: "Search for memos",
                  labelStyle: TextStyle(color: const Color(0xFF679436)),
                  //focusColor: const Color(0xFF679436),
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF679436)),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF679436)),
                  ),
                ),
                keyboardType: TextInputType.text,
                style: GoogleFonts.ubuntu(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 5.0, left: 5.0),
              child: GestureDetector(
                child: Icon(Icons.search),
                onTap: () {
                  //Use the keyword to search the DB for memos with that tag
                  if (searchController.text.isNotEmpty) {
                    setState(() {
                      widget.updateSearchQuery(
                          searchController.text.toLowerCase());
                      searchController.text = "";
                    });
                  }
                },
              ),
            ),
          ],
        ));
  }

  Widget getTaskMenu() {
    return Container(
        height: 40,
        margin: EdgeInsets.only(top: 5.0),
        child: ListView(
            // This next line does the trick.
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: FlatButton(
                    onPressed: () {
                      //Should sort list by most likes or something
                      setState(() {
                        widget.updateSearchQuery();
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.bubble_chart,
                          color: const Color(0xFF679436),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2.0, top: 2.0),
                          child: Text(
                            "View All",
                            style: GoogleFonts.ubuntu(
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )),
              ),
              VerticalDivider(
                thickness: 1.0,
                color: Colors.grey[200],
                width: 5.0,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: FlatButton(
                    onPressed: () {
                      //Bring to recording screen
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RecordingScreen((widget.user))));
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.mic,
                          color: const Color(0xFF679436),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2.0, top: 2.0),
                          child: Text(
                            "Record",
                            style: GoogleFonts.ubuntu(
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )),
              ),
              VerticalDivider(
                thickness: 1.0,
                color: Colors.grey[200],
                width: 5.0,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: FlatButton(
                    onPressed: () {
                      //Bring to user profile page
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => ProfileScreen(
                                  widget.user, widget.user["id"])));
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.person_outline,
                          color: const Color(0xFF679436),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2.0, top: 2.0),
                          child: Text(
                            "My Profile",
                            style: GoogleFonts.ubuntu(
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )),
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            getSearchBar(),
            getTaskMenu(),
            Container(
              margin: EdgeInsets.only(right: 25.0, left: 15.0),
              child: Divider(
                height: 5.0,
                thickness: 1.0,
                color: Colors.grey[200],
              ),
            ),
          ],
        ));
  }
}
