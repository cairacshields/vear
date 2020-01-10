import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vear/services/database.dart';
import 'package:vear/services/storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:date_format/date_format.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tags/tag.dart';
import 'package:event_bus/event_bus.dart';
import 'package:vear/objects/loading_event.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:vear/screens/home_screen.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RecordingScreen extends StatefulWidget {
  final dynamic user;
  RecordingScreen(this.user);

  @override
  State<StatefulWidget> createState() {
    return _RecordingScreenState();
  }
}

class _RecordingScreenState extends State<RecordingScreen> {
  Database _database = Database();
  Storage _storage = Storage();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FlutterSound flutterSound = new FlutterSound();
  StreamSubscription<RecordStatus> _recorderSubscription;

  bool _loading = false;
  File _image;

  // Create some text controllers. Later, use them to retrieve the
  // current value of the TextFields.
  final titleController = TextEditingController();
  final descriprionController = TextEditingController();
  final tagsController = TextEditingController();

  bool isRecording = false;
  File recordingFile;
  List<String> tags = [];

  final emptyFieldError = SnackBar(
    content: Text("Error: Please complete all fields!"),
  );

  final stillRecording = SnackBar(
    content: Text("Error: Please stop recording before upload!"),
  );

  final uploadError = SnackBar(
    content: Text("Error: unable to upload memo, please try again!"),
  );

  final noRecording = SnackBar(
    content: Text("Recording and image required"),
  );

  void setUpLoadingListener() {
    EventBus eventBus = _storage.eventBus;
    eventBus.on<LoadingEvent>().listen((event) {
      // All events are of type UserLoggedInEvent (or subtypes of it).
      setState(() {
        _loading = event.isLoading;
      });
    });
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) async {
        if (image != null) {
          setState(() {
            _image = image;
          });
        }
      }).catchError((error){
        print("Error opening image picker: $error");
      });
  }

  void onTagsFieldChanged() {
    if (tagsController.text.contains(",")) {
      setState(() {
        tags.add(tagsController.text.split(",")[0].toLowerCase());
        tagsController.text = "";
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tagsController.addListener(onTagsFieldChanged);
    setUpLoadingListener();
  }

  @override
  void dispose() {
    flutterSound.stopRecorder();
    titleController.dispose();
    descriprionController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Widget getRecordButton() {
    return Container(
      child: GestureDetector(
        child: Container(
          child: Icon(
            Icons.play_arrow,
            size: 100.0,
            color: const Color(0xFFEEF5DB),
          ),
        ),
        onTap: () async {
          //Start recording
          setState(() {
            isRecording = true;
          });
          await flutterSound
              .startRecorder(Platform.isIOS ? 'ios.aac' : 'android.aac')
              .then((path) {
            print('startRecorder: $path');

            _recorderSubscription =
                flutterSound.onRecorderStateChanged.listen((e) {
              DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                  e.currentPosition.toInt());
              String txt = formatDate(date, [mm, ":", ss, ":", SSS]);
              print(txt);
            });
          }).catchError((error) {
            print("Error starting recording: $error");
          });
        },
      ),
    );
  }

  Widget getStopRecordButton() {
    return Container(
      child: GestureDetector(
        child: Icon(
          Icons.stop,
          size: 100.0,
          color: const Color(0xFFEEF5DB),
        ),
        onTap: () async {
          setState(() {
            isRecording = false;
          });
          //Stop recording
          await flutterSound.stopRecorder().then((value) {
            //Value should hold our audio file
            print('stopRecorder: ${value.substring(8)}');

            recordingFile = File(value.substring(8));

            if (_recorderSubscription != null) {
              _recorderSubscription.cancel();
              _recorderSubscription = null;
            }
          }).catchError((error) {
            print("Error stoping recoring: $error");
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Record"),
        backgroundColor: const Color(0xFF679436),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200.0,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF5DB),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  ),
                  isRecording == true
                      ? Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.only(left: 30.0),
                          child: Image.asset(
                            "assets/gifs/recording.gif",
                            height: 125.0,
                            width: 125.0,
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.only(left: 30.0, top: 60.0),
                          child: Text(
                            "Press play to record",
                            style: GoogleFonts.ubuntu(
                                textStyle: TextStyle(fontSize: 35.0)),
                          ),
                        ),
                  Container(
                    width: 120.0,
                    height: 120.0,
                    margin: EdgeInsets.only(top: 40.0, left: 250.0),
                    decoration: BoxDecoration(
                        color: const Color(0xFF679436),
                        borderRadius: BorderRadius.all(Radius.circular(100.0))),
                    child: isRecording == false
                        ? getRecordButton()
                        : getStopRecordButton(),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 15.0),
                child: Text(
                  "Describe your memo",
                  style:
                      GoogleFonts.ubuntu(textStyle: TextStyle(fontSize: 25.0)),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                    child: TextFormField(
                      controller: titleController,
                      cursorColor: const Color(0xFF679436),
                      decoration: InputDecoration(
                        labelText: "Enter Memo Title",
                        labelStyle: TextStyle(color: const Color(0xFF679436)),
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide:
                              BorderSide(color: const Color(0xFF679436)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide:
                              BorderSide(color: const Color(0xFF679436)),
                        ),
                      ),
                      validator: (val) {
                        if (val.length == 0) {
                          return "Title cannot be empty";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.ubuntu(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                    child: TextFormField(
                      controller: descriprionController,
                      cursorColor: const Color(0xFF679436),
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Memo Description",
                        labelStyle: TextStyle(color: const Color(0xFF679436)),
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide:
                              BorderSide(color: const Color(0xFF679436)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide:
                              BorderSide(color: const Color(0xFF679436)),
                        ),
                      ),
                      validator: (val) {
                        if (val.length <= 10) {
                          return "Description must be longer than 10 characters";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.ubuntu(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                    child: TextFormField(
                      controller: tagsController,
                      cursorColor: const Color(0xFF679436),
                      decoration: InputDecoration(
                        labelText: "Add Memo Tags",
                        labelStyle: TextStyle(color: const Color(0xFF679436)),
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide:
                              BorderSide(color: const Color(0xFF679436)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide:
                              BorderSide(color: const Color(0xFF679436)),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.ubuntu(),
                    ),
                  ),
                  tags.length > 0
                      ? Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Tags(
                              itemCount: tags.length,
                              itemBuilder: (int index) {
                                return ItemTags(
                                  index: index,
                                  title: tags[index],
                                  activeColor: const Color(0xFFEEF5DB),
                                  textColor: Colors.black,
                                  textActiveColor: Colors.black,
                                  //textStyle:GoogleFonts.ubuntu(),
                                  removeButton: ItemTagsRemoveButton(icon: Icons.close, ),
                                  onRemoved: (){
                                    setState(() {
                                      tags.removeAt(index);
                                    });
                                  },
                                );
                              }),
                        )
                      : SizedBox(),
                  Container(
                    margin: EdgeInsets.only(bottom: 25.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: const Color(0xFF679436))),
                      onPressed: () async {
                        //Should open image picker
                        await chooseFile();
                      },
                      color: const Color(0xFF679436),
                      textColor: Colors.white,
                      child: Text("Upload Image".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  !_loading ? RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: const Color(0xFF679436))),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        //Make sure we're not still recording
                        if (recordingFile != null && _image != null) {
                          if (_recorderSubscription != null) {
                            _scaffoldKey.currentState.showSnackBar(
                                stillRecording);
                          } else {
                            //We seem to be gtg!
                            _storage.uploadUserRecording(
                                widget.user["id"], titleController.text,
                                descriprionController.text, tags, _image ,recordingFile)
                                .then((downloadUrl) {
                              if (downloadUrl != null) {
                                showDialog(
                                    context: context,
                                    builder: (_) => NetworkGiffyDialog(
                                      image: Image.network(
                                        "https://media.giphy.com/media/yoJC2El7xJkYCadlWE/giphy.gif",
                                        fit: BoxFit.cover,
                                      ),
                                      entryAnimation: EntryAnimation.TOP_LEFT,
                                      title: Text(
                                        'Thanks for the contribution!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 22.0, fontWeight: FontWeight.w600),
                                      ),
                                      description: Text(
                                        'Sharing your words will help shape the world! Please keep contributing.',
                                        textAlign: TextAlign.center,
                                      ),
                                      onCancelButtonPressed: (){
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (BuildContext context) =>
                                                    HomeScreen((widget.user))));
                                      },
                                      buttonOkText: Text("Go Home"),
                                      onOkButtonPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (BuildContext context) =>
                                                    HomeScreen((widget.user))));
                                      },
                                    ));
                              }
                            }).catchError((error) {
                              print("Error uploading user recording: $error");
                              _scaffoldKey.currentState.showSnackBar(
                                  uploadError);
                            });
                          }
                        } else {
                          print("No recording file or image loaded");
                          _scaffoldKey.currentState.showSnackBar(
                              noRecording);
                        }
                      }
                    },
                    color: const Color(0xFF679436),
                    textColor: Colors.white,
                    child: Text("Upload Recording".toUpperCase(),
                        style: TextStyle(fontSize: 14)),
                  ): CircularProgressIndicator(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
