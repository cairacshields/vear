import 'package:flutter/material.dart';
import 'package:vear/services/database.dart';
import 'package:easy_dialog/easy_dialog.dart';


class CommentDialog extends StatelessWidget {
  Database _database = Database();
  final String creatorId;
  final String commenterId;
  final String recordingTitle;

  CommentDialog(this.recordingTitle, this.creatorId, this.commenterId);

  final messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();

  final messageFieldEmpty = SnackBar(content: Text("Please enter a message."));
  final messageSendingError =
  SnackBar(content: Text("Sending message failed."));

  void addRecordingComment(BuildContext context) async {
    await _database
        .addRecordingComment(creatorId, commenterId,
        recordingTitle, messageController.text)
        .then((value) {
      //Close the dialog...
      Navigator.of(context).pop();
    }).catchError((error) {
      print("Error adding comment to recording in DB: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return EasyDialog(
        cornerRadius: 15.0,
        fogOpacity: 0.1,
        width: 280,
        height: 180,
        contentPadding:
        EdgeInsets.only(top: 12.0), // Needed for the button design
        contentList: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 30.0)),
                Text("Rate",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textScaleFactor: 1.3,
                ),
                Padding(padding: EdgeInsets.only(left: 10.0)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < 3 ? Icons.star : Icons.star_border,
                      size: 30.0,
                      color: Colors.orange,
                    );
                  }),
                )],),
          ),
          Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Add review",
                  ),
                ),
              )),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))),
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Rate",
                textScaleFactor: 1.3,
              ),),
          ),
        ]).show(context);
  }
}