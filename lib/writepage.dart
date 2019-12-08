import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

class WritePage extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  WritePage({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  Recording _recording = new Recording();

  Random random = new Random();
  TextEditingController _controller = new TextEditingController();
  bool _isRecording = false; // 녹음 파일 유무 확인
  bool _isPlaying = false;
  bool _hasRecFile = false;

  bool hasFile = false;
  int fileNum = 0;
  io.Directory appDocDirectory;

  String audioPath;

  List liRecFiles = new List();

  @override
  Widget build(BuildContext context) {
    //return Scaffold(
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 10,
            child: CircleAvatar(
              radius: 54,
              backgroundColor: _isRecording ? Colors.white : Colors.black,
              child: CircleAvatar(
                child: IconButton(
                  icon: _hasRecFile ? (_isPlaying ? Icon(Icons.stop)  : Icon(Icons.play_arrow)) : Icon(Icons.mic),
                  color: _isRecording ? Colors.white : Colors.black,
                  iconSize: 40,
                  alignment: Alignment.center,
                  onPressed: () {
                    _hasRecFile ? (_isPlaying ? _stopPlayRec() : _playRec()) : (_isRecording ? voiceRecordStop() : voiceRecordStart());
                    //_search();
                    // setState(() {
                      
                    // });
                  },
                ),
                radius: 50,
                backgroundColor: _isRecording ? Colors.pink[200] : Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 20, bottom: 20),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.refresh),
                        Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        Text("re-Recording"),
                      ],
                    ),
                    onPressed: () {
                       setState(() {
                          _deleteRec();
                       });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                ),
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    color: Colors.white,
                    padding: EdgeInsets.only(right: 20, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(Icons.send),
                        Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        Text("Send"),
                      ],
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // body: ListView.builder(
    //   itemCount: RecFilesFileName.length,
    //   itemBuilder: (BuildContext context, int index) {

    //   },

    //   floatingActionButton: FloatingActionButton.extended(
    //     onPressed: () {
    //       _isMicPushed ? voiceRecordStop() : voiceRecordStart();
    //       setState(() {
    //         _search();
    //       });
    //     },
    //     label: Text('Record'),
    //     icon: Icon(Icons.mic),
    //     foregroundColor: Colors.black,
    //     backgroundColor: _isMicPushed ? Colors.pink : Colors.white,
    //   ),
    // );
  }

  voiceRecordStart() {
    _isRecording ? null : _start();
    // _isMicPushed = true;
  }

  voiceRecordStop() {
    _isRecording ? _stop() : null;
    // _isMicPushed = false;
  }

  AudioPlayer audioPlayer = AudioPlayer();
  _playRec() async{
    print("Search recording file : " + audioPath);

    try{
      io.File fiRec = io.File(audioPath);
      if(fiRec.existsSync()) {
        int result = await audioPlayer.play(audioPath, isLocal: true);
        if (result == 1) {
          _isPlaying = true;
          print("Success");
        }
         else
        {
          print("Fail");
        }
        setState(() {
          
        });
      }
    }
    catch(Exception){
    }
  }

  _stopPlayRec() async{
    print("Search recording file : " + audioPath);

    try{
      int result = await audioPlayer.stop();
      if (result == 1) {
        _isPlaying = false;
        print("Success");
      }
        else
      {
        print("Fail");
      }
      setState(() {
          
        });
    }
    catch(Exception){
    }
  }


  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        appDocDirectory = await getApplicationDocumentsDirectory();
        var now = DateTime.now();
        String formattedDate = DateFormat('yyyyMMddhhmmss').format(now);
        String path = appDocDirectory.path + '/' + formattedDate + ".m4a";
        audioPath = path;
        print("Start recording: $path");
        await AudioRecorder.start(
            path: path, audioOutputFormat: AudioOutputFormat.AAC);

        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = widget.localFileSystem.file(recording.path);
    print("  File length: ${await file.length()}");
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
      _search();
    });
    _controller.text = recording.path;
  }

  _search() async {
    print("Search recording file : " + appDocDirectory.path);

    try {
      String directory = appDocDirectory.path;
      liRecFiles = io.Directory("$directory/").listSync();
      if(liRecFiles.length > 0) { _hasRecFile = true; }
      else { _hasRecFile = false; }
    } catch (Exception) {}
  }

  _deleteRec() async{
    print ("Delete recording dir : " + appDocDirectory.path);

    try{
      String directory = appDocDirectory.path;
      io.Directory diRec = io.Directory("$directory/");
      if(diRec.existsSync()){
        diRec.deleteSync(recursive: true);
        _hasRecFile = false;
      }
  
    }
    catch(Exception) {}
  }
}
