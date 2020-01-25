import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vear/objects/recording.dart';
import 'package:marquee/marquee.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:vear/services/database.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:vear/reusables/comment_dialog.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:date_format/date_format.dart';


class PlayerScreen extends StatefulWidget {
  final Recording activeRecording;
  final String currentUserId;
  final String creatorId;

  PlayerScreen(this.activeRecording, this.creatorId, this.currentUserId);

  @override
  State<StatefulWidget> createState() {
    return _PlayerScreenState();
  }
}

class _PlayerScreenState extends State<PlayerScreen> {
  Database _database = Database();
  AudioPlayer audioPlayer = AudioPlayer();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Duration playerPosition;
  Duration recordingDurartion = Duration();
  String textDuration;

  final messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();

  final messageFieldEmpty = SnackBar(content: Text("Please enter a message."));
  final messageSendingError =
      SnackBar(content: Text("Sending message failed."));
  final commentSuccess = SnackBar(content: Text("Comment added!"));
  final commentError = SnackBar(content: Text("Error adding comment, please try again."));

  double playPercentage = 0.0;
  AudioPlayerState playerState;

  String currentUserLiked = "";
  int likes = 0;
  int disLikes = 0;

  dynamic recordingComments;
  var comments = [];

  PaletteGenerator _paletteGenerator;

  Color bodyColor;
  Color titleColor;
  Color backgroundColor;

  void getPalette(NetworkImage paletteImage) {
    PaletteGenerator.fromImageProvider(paletteImage).then((value) {
      setState(() {
        _paletteGenerator = value;

        bodyColor = _paletteGenerator.vibrantColor != null
            ? _paletteGenerator.vibrantColor.bodyTextColor
            : Colors.black;
        titleColor = _paletteGenerator.vibrantColor != null
            ? _paletteGenerator.vibrantColor.titleTextColor
            : Colors.black;
        backgroundColor = _paletteGenerator.vibrantColor != null
            ? _paletteGenerator.vibrantColor.color
            : Colors.black26;
      });
    }).catchError((error) {
      print("Error grabbing Palette from image provided: $error");
    });
  }

  NetworkImage getRecordingImage() {
    return NetworkImage(
      widget.activeRecording.recordingImage,
    );
  }

  void addRecordingComment(BuildContext context) async {
    await _database
        .addRecordingComment(widget.creatorId, widget.currentUserId,
        widget.activeRecording.recordingTitle, messageController.text)
        .then((value) {
      //show success dialog
      _scaffoldKey.currentState.showSnackBar(commentSuccess);
    }).catchError((error) {
      _scaffoldKey.currentState.showSnackBar(commentError);
      print("Error adding comment to recording in DB: $error");
    });
  }

  void getRecordingComments() async {
    await _database
        .getRecordingComments(
            widget.creatorId, widget.activeRecording.recordingTitle)
        .then((value) {
      if (value != null) {
        setState(() {
          recordingComments = value;
        });
      }
    }).catchError((error) {
      print("Error getting comments for recording: $error");
    });

    unpackRecordingComments();
  }

  void unpackRecordingComments() async {
    if (recordingComments != null) {
      (recordingComments as Map<dynamic, dynamic>).forEach((key, value) async {
        await _database.getUser(value["commenterId"])
            .then((user){
          comments.add({"comment": value["comment"], "commenter": user, "time": value["time"]});
        }).catchError((error){
          print("Error getting commenter $error");
        });
      });
    }
  }

  void submitLikeOrDislike(bool liked) async {
    await _database
        .likeOrDislikeRecording(liked, widget.creatorId, widget.currentUserId,
            widget.activeRecording.recordingTitle)
        .then((value) async {
      setState(() {
        getRecordingLikes();
      });
    }).catchError((error) {
      print("Error adding new like or dislike: $error");
    });
  }

  void getRecordingLikes() async {
    await _database
        .getRecordingLikes(widget.activeRecording.recordingTitle)
        .then((value) {
      int recordingLikes = 0;
      int recordingDisLikes = 0;

      if (value != null) {
        (value).forEach((k, v) {
          if (v["liked"] == "like") {
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
    }).catchError((error) {
      print("Error getting likes for recording: $error");
    });
  }

  void setDurationText(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    setState(() {
      textDuration =
          "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    });
  }

  void getRecordingDuration() async {
    await audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() {
        recordingDurartion = d;
        setDurationText(recordingDurartion);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AudioPlayer.logEnabled = true;

    print("Recording URL: ${widget.activeRecording.recordingUrl}");
    audioPlayer.setUrl(widget.activeRecording.recordingUrl);
    getRecordingDuration();
    setPlayerListeners();

    getRecordingLikes();
    getRecordingComments();
    print("Comments: $recordingComments");
    getPalette(getRecordingImage());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    audioPlayer.release();
    audioPlayer.dispose();
    super.dispose();
  }

  void setPlayerListeners() {
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      print('Current position: ${p}');
      playerPosition = p;
      setState(() {
        playPercentage = double.parse(
            ((playerPosition.inSeconds / recordingDurartion.inSeconds * 1000) /
                    1000)
                .toStringAsFixed(2));
        print(playPercentage);
      });
    });

    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        if (playerPosition != null) {
          playPercentage = 1.0;
          stopRecording();
        }
      });
    });

    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
      print('Current player state: $s');
      setState(() {
        playerState = s;
      });
    });
  }

  void playRecording() async {
    int result = await audioPlayer.resume();
    if (result == 1) {
      // success
      print("Playing audio success");
    }
  }

  void pauseRecording() async {
    int result = await audioPlayer.pause();
    if (result == 1) {
      // success
      print("Pausing success");
    }
  }

  void resumeRecording() async {
    int result = await audioPlayer.resume();
    if (result == 1) {
      // success
      print("Resuming audio success");
    }
  }

  void stopRecording() async {
    int result = await audioPlayer.stop();
    if (result == 1) {
      // success
      print("Stopping playback success");
    }
  }

  Widget getPlayerRecordingImage() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Center(
        child: Card(
            elevation: 10.0,
            child: Container(
                child: Image(
              height: MediaQuery.of(context).size.height / 3,
              width: 320.0,
              fit: BoxFit.cover,
              image: getRecordingImage(),
            ))),
      ),
    );
  }

  Widget getPlayerRecordingTitleSection() {
    return Container(
      height: 25.0,
      width: 250.0,
      margin: EdgeInsets.only(top: 20.0),
      child: Center(
        child: Marquee(
          text: widget.activeRecording.recordingTitle,
          style: GoogleFonts.ubuntu(
              textStyle: TextStyle(fontSize: 22.0, color: Colors.white)),
          blankSpace: 60.0,
          velocity: 100.0,
          pauseAfterRound: Duration(seconds: 1),
          startPadding: 10.0,
          accelerationDuration: Duration(seconds: 2),
          accelerationCurve: Curves.easeInToLinear,
          decelerationDuration: Duration(milliseconds: 500),
        ),
      ),
    );
  }

  Widget getPlayerRecordingDescription() {
    return Container(
      height: MediaQuery.of(context).size.height / 6,
      width: 320.0,
      margin: EdgeInsets.only(top: 20.0),
      child: SingleChildScrollView(
        child: Center(
          child: Text(
            widget.activeRecording.recordingDescription,
            style: GoogleFonts.ubuntu(
                textStyle: TextStyle(
                    fontSize: 15.0, color: bodyColor, wordSpacing: 2.0)),
          ),
        ),
      ),
    );
  }

  Widget getPlayerProgressBar() {
    return Container(
      margin: EdgeInsets.only(left: 25.0, right: 10.0, top: 20.0),
      child: Center(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: new LinearPercentIndicator(
                width: MediaQuery.of(context).size.width / 1.7,
                animation: true,
                animationDuration: 1000,
                lineHeight: 15.0,
                leading: new Text("00:00"),
                trailing:
                    textDuration != null ? Text(textDuration) : Text("00:00"),
                percent: playPercentage,
                animateFromLastPercent: true,
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Colors.white,
              ),
            )),
      ),
    );
  }

  Widget getPlayerControls() {
    return Container(
      margin: EdgeInsets.only(left: 100.0, top: 20.0),
      child: Center(
        child: Row(
          children: <Widget>[
            Container(
                margin: EdgeInsets.all(10.0),
                child: GestureDetector(
                  child: Icon(
                    Icons.thumb_down,
                    color: currentUserLiked == "dislike"
                        ? Colors.white
                        : Colors.black12,
                    size: 40.0,
                  ),
                  onTap: () {
                    submitLikeOrDislike(false);
                  },
                )),
            Container(
                margin: EdgeInsets.all(10.0),
                child: GestureDetector(
                  child: Icon(
                    playerState == AudioPlayerState.PLAYING
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  onTap: () {
                    if (playerState == AudioPlayerState.PLAYING) {
                      pauseRecording();
                    } else if (playerState == AudioPlayerState.STOPPED) {
                      audioPlayer.play(widget.activeRecording.recordingUrl);
                    } else if (playerState == AudioPlayerState.PAUSED) {
                      resumeRecording();
                    } else {
                      playRecording();
                    }
                  },
                )),
            Container(
                margin: EdgeInsets.all(10.0),
                child: GestureDetector(
                  child: Icon(
                    Icons.thumb_up,
                    color: currentUserLiked == "like"
                        ? Colors.white
                        : Colors.black12,
                    size: 40.0,
                  ),
                  onTap: () {
                    submitLikeOrDislike(true);
                  },
                )),
          ],
        ),
      ),
    );
  }

  showAllComments(context) {
    getRecordingComments();

    EasyDialog(
        cornerRadius: 15.0,
        fogOpacity: 0.1,
        width: 340,
        height: 300,
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
                Text(
                  "All Comments",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textScaleFactor: 1.3,
                ),
                Padding(padding: EdgeInsets.only(left: 10.0)),
                Icon(Icons.all_inclusive)
              ],
            ),
          ),

          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))),
            child: comments.length > 0 ?Container(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                ),
                shrinkWrap: true,
                //scrollDirection: Axis.vertical,
                physics:  AlwaysScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (BuildContext context, int index) {
                  var comment = comments[index]["comment"];
                  return ListTile(
                    title: Text(comment),
                    subtitle: Text("By: ${comments[index]["commenter"]["full_name"]}"),
                    trailing: Text(formatDate(DateTime.parse(comments[index]["time"]), [yy, '-', mm, '-', dd])),
                  );
                },
              ),
            ) :
                Container(
                   child: Center(
                     child: Text("No Comments"),
                   ),
                )
          ),
        ]).show(context);
  }

  navToCommentDialog(context) async {
    EasyDialog(
        cornerRadius: 15.0,
        fogOpacity: 0.1,
        width: 340,
        height: 200,
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
                Text(
                  "Add comment",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textScaleFactor: 1.3,
                ),
                Padding(padding: EdgeInsets.only(left: 10.0)),
                Icon(Icons.add)
              ],
            ),
          ),
          Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: messageController,
                  focusNode: messageFocusNode,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        "Add your comment to: ${widget.activeRecording.recordingTitle}",
                  ),
                ),
              )),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))),
            child: FlatButton(
              onPressed: () {
                //Close the dialog
                Navigator.of(context).pop();

                //Upload comment
                addRecordingComment(context);
              },
              child: Text(
                "Submit",
                textScaleFactor: 1.3,
              ),
            ),
          ),
        ]).show(context);
  }

  @override
  Widget build(BuildContext context) {
    double _sigmaX = 0.0; // from 0-10
    double _sigmaY = 0.0; // from 0-10
    double _opacity = 0.1; // from 0-1.0

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Player",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: FabCircularMenu(
        child: Container(
          child: Container(
              child: Stack(
            children: <Widget>[
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                child: Container(
                  color: Colors.black.withOpacity(_opacity),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    getPlayerRecordingImage(),
                    getPlayerRecordingTitleSection(),
                    getPlayerRecordingDescription(),
                    getPlayerProgressBar(),
                    getPlayerControls()
                  ],
                ),
              ),
            ],
          )),
        ),
        ringColor: Colors.white30,
        fabColor: Colors.white,
        fabOpenIcon: Icon(
          Icons.chat_bubble_outline,
          color: Colors.black,
        ),
        fabCloseIcon: Icon(
          Icons.close,
          color: Colors.black,
        ),
        ringDiameter: 200,
        options: <Widget>[
          IconButton(
              icon: Icon(Icons.add_comment),
              onPressed: () {
                //Open dialog to add new comment
                navToCommentDialog(context);
              },
              iconSize: 38.0,
              color: Colors.white),
          IconButton(
              icon: Icon(Icons.format_align_left),
              onPressed: () {
                //Should open all comments for recording page
                showAllComments(context);
              },
              iconSize: 38.0,
              color: Colors.white),
        ],
      ),
    );
  }
}
