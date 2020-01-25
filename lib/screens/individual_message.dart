import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vear/services/database.dart';
import 'package:bubble/bubble.dart';

class IndividualMessageScreen extends StatefulWidget {
  final dynamic messagingUserId;
  final dynamic messagingUserFullName;
  final String currentUid;
  final dynamic currentUser;

  IndividualMessageScreen(this.messagingUserId, this.messagingUserFullName, this.currentUid, this.currentUser);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IndividualMessageScreenState();
  }
}

class _IndividualMessageScreenState extends State<IndividualMessageScreen> {
  Database _database = Database();
  final messageController = TextEditingController();

  final messageFieldEmpty = SnackBar(content: Text("Please enter a message."));
  final messageSendingError = SnackBar(content: Text("Sending message failed."));

  Widget chatInterfaceMainWidget() {
    //database reference.
    var chatsRef = FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(widget.currentUid)
        .child("messages")
        .child(widget.messagingUserId)
        .child("messages")
        .orderByChild('time');

    //Now you can use stream builder to get the data.
    return StreamBuilder(
      stream: chatsRef.onValue,
      builder: (context, snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          //taking the data snapshot.
          DataSnapshot snapshot = snap.data.snapshot;
          var items = [];
          Map<dynamic, dynamic> _map;
          //it gives all the documents in this list.
          _map = snapshot.value;
          //Now we're just checking if document is not null then add it to another list called "item".
          //I faced this problem it works fine without null check until you remove a document and then your
          // stream reads data including the removed one with a null value(if you have some better approach let me know).
          _map.forEach((k, v) {
            items.add(v);
          });

          //Sort the chats by date_created
          items.sort((a, b) => a["time"].compareTo(b["time"]));

          return snap.data.snapshot.value == null
          //return empty state if there's nothing in database.
              ? Container(
            margin: EdgeInsets.only(top: 50.0),
            child: Center(
              child: Text("No messages yet, send one."),
            ),
          )
          //otherwise return a list of widgets.
              : ListView.builder(
            shrinkWrap: true,
            //scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              var message = items[index];
              return message["sender"] == widget.currentUid
                  ? Container(
                margin: EdgeInsets.only(left: 35.0),
                child: Bubble(
                  margin: BubbleEdges.only(top: 10),
                  nip: BubbleNip.rightTop,
                  color: const Color(0xFF679436),
                  child: Text(
                    message["text"],
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  style: BubbleStyle(
                    margin: BubbleEdges.all(10.0),
                  ),
                ),
              )
                  : Container(
                margin: EdgeInsets.only(right: 35.0),
                child: Bubble(
                  margin: BubbleEdges.only(top: 10),
                  nip: BubbleNip.leftBottom,
                  color: Colors.grey[200],
                  child: Text(
                    message["text"],
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  style: BubbleStyle(
                    margin: BubbleEdges.all(10.0),
                  ),
                ),
              );
            },
          );
        } else {
          print("From chat stream");
          return Container(
            margin: EdgeInsets.only(top: 50.0),
            child: Center(
              child: Text("No messages yet, send one."),
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
        title: Text(widget.messagingUserFullName),
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
                Container(
                    margin: EdgeInsets.only(bottom: 35.0, left: 15.0, right: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            keyboardType: TextInputType.text,
                            cursorColor: const Color(0xFF679436),
                            decoration: InputDecoration(
                              hintText: "Type a message",
                              focusColor: const Color(0xFF679436),
                              focusedBorder:
                              UnderlineInputBorder(borderSide: BorderSide()),
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.send,
                            color: const Color(0xFF679436),
                          ),
                          onTap: () async {
                            if (messageController.text.isNotEmpty) {
                              await _database
                                  .sendChat(widget.messagingUserId, widget.currentUid, widget.currentUser["full_name"],
                                  messageController.text)
                                  .then((value) {
                                if (value != false) {
                                  setState(() {
                                    messageController.text = "";
                                  });
                                } else {
                                  Scaffold.of(context).showSnackBar(messageSendingError);
                                }
                              }).catchError((error) {
                                Scaffold.of(context).showSnackBar(messageSendingError);
                              });
                            } else {
                              //Nothing in text field
                              Scaffold.of(context).showSnackBar(messageFieldEmpty);
                            }
                          },
                        )
                      ],
                    )),
              ])),
    );
  }
}