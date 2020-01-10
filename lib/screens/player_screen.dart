import 'package:flutter/material.dart';
import 'package:vear/objects/recording.dart';
import 'package:marquee/marquee.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:vear/services/database.dart';

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

  Duration playerPosition;
  int recordingDurartion = 0;

  double playPercentage = 0;
  AudioPlayerState playerState;

  String currentUserLiked = "";
  int likes = 0;
  int disLikes = 0;

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

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void getRecordingDuration() async {
    await audioPlayer.getDuration().then((value) {
      setState(() {
        recordingDurartion = value;
      });
    }).catchError((error) {
      print("Error grabbing audio duraration... : $error");
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
    getRecordingLikes();
    setPlayerListeners();
    playRecording();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.dispose();
  }

  void setPlayerListeners() {
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      print('Current position: ${p}');
      playerPosition = p;
      setState(() {
        playPercentage = (playerPosition.inSeconds / recordingDurartion * 1000);
        print(playPercentage);
      });
    });

    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        playPercentage = 1.0;
        stopRecording();
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
              height: 320.0,
              width: 320.0,
              fit: BoxFit.cover,
              image: new NetworkImage(
                widget.activeRecording.recordingImage,
              ),
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
          //decelerationCurve: Curves.easeInToLinear,
        ),
      ),
    );
  }

  Widget getPlayerRecordingDescription() {
    return Container(
      height: 200.0,
      width: 320.0,
      margin: EdgeInsets.only(top: 20.0),
      child: SingleChildScrollView(
        child: Center(
          child: Text(
            "Contrary to popular belief  Lorem Ipsum is not simply random text."
            " It has roots in a piece of classical Latin literature from 45 BC "
            "making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney "
            "College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem "
            "Ipsum passage, and going through the cites of the word in classical literature, "
            "discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 "
            "of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written "
            "in 45 BC. This book is a treatise on the theory of ethics, very popular during the"
            " Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet..,"
            " comes from a line in section 1.10.32.",
            style: GoogleFonts.ubuntu(
                textStyle: TextStyle(
                    fontSize: 15.0, color: Colors.grey[800], wordSpacing: 2.0)),
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
                leading: new Text("0:00"),
                trailing: new Text(
                    "${_printDuration(Duration(milliseconds: recordingDurartion))}"),
                percent: playPercentage,
                animateFromLastPercent: true,
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: const Color(0xFF679436),
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
                        ? const Color(0xFF679436)
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
                    color: const Color(0xFF679436),
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
                        ? const Color(0xFF679436)
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("Player"),
        backgroundColor: const Color(0xFF679436),
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: Container(
        child: SingleChildScrollView(
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
      ),
    );
  }
}
