import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vear/services/database.dart';
import 'package:vear/reusables/message_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vear/screens/individual_message.dart';

class MessageScreen extends StatefulWidget {
  final dynamic user;

  MessageScreen(this.user);

  @override
  State<StatefulWidget> createState() {
    return _MessageScreenState();
  }
}

class _MessageScreenState extends State<MessageScreen> {
  final messageController = TextEditingController();
  final Database _database = Database();

  Widget chatInterfaceMainWidget() {
    //database reference.
    var chatsRef = FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(widget.user["id"])
        .child("messages");

    //Now you can use stream builder to get the data.
    return StreamBuilder(
      stream: chatsRef.onValue,
      builder: (context, snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          //taking the data snapshot.
          DataSnapshot snapshot = snap.data.snapshot;
          Map<dynamic, dynamic> items = {};
          Map<dynamic, dynamic> _map;

          var allMessages = [];

          //it gives all the documents in this list.
          _map = snapshot.value;
          //Now we're just checking if document is not null then add it to another list called "item".
          //I faced this problem it works fine without null check until you remove a document and then your
          // stream reads data including the removed one with a null value(if you have some better approach let me know).
          _map.forEach((k, v) {
            v.forEach((key, value) {
              value.forEach((key2, value2) {
                if (items != null) {
                  if (!items.containsKey(value2["sender_name"]) &&
                      value2["sender"] != widget.user["id"]) {
                    items.addAll({value2["sender_name"]: value2["sender"]});
                  }
                } else {
                  items.addAll({value2["sender_name"]: value2["sender"]});
                }
              });
            });
          });

          return snap.data.snapshot.value == null
              //return empty state if there's nothing in database.
              ? Container(
                  margin: EdgeInsets.only(top: 150.0),
                  child: Center(
                    child: Text("No messages yet."),
                  ),
                )
              //otherwise return a list of widgets.
              : ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.black,
                  ),
                  shrinkWrap: true,
                  //scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      // Each Dismissible must contain a Key. Keys allow Flutter to
                      // uniquely identify widgets.
                      background: Container(color: Colors.red),
                      key: Key(items.entries.elementAt(index).key),
                      // Provide a function that tells the app
                      // what to do after an item has been swiped away.
                      onDismissed: (direction) async {
                        // Remove the item from the data source.
                        _database
                            .removeChat(widget.user["id"],
                                items.entries.elementAt(index).value)
                            .then((value) {
                          if (value != false) {
                            //Don't think we need to do anything
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text("Message removed")));
                          }
                        }).catchError((error) {
                          print("Error deleting message: $error");
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text("Error removing message")));
                        });
                      },
                      child: ListTile(
                        title: Text(
                          items.entries.elementAt(index).key,
                          style: GoogleFonts.ubuntu(
                              textStyle: TextStyle(
                                  fontSize: 15.0, color: Colors.black)),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      IndividualMessageScreen(
                                          items.entries.elementAt(index).value,
                                          items.entries.elementAt(index).key,
                                          widget.user["id"],
                                          widget.user)));
                        },
                      ),
                    );
                  },
                );
        } else {
          print("From chat stream");
          return Container(
            margin: EdgeInsets.only(top: 150.0),
            child: Center(
              child: Text("No messages yet."),
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF679436),
        centerTitle: true,
        title: Text("Messages"),
      ),
      body: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Container(child: chatInterfaceMainWidget()),
              ),
            ),
          ])),
    );
  }
}
