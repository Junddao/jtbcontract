import 'dart:math';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';
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
  bool _isRecording = false;
  Random random = new Random();
  TextEditingController _controller = new TextEditingController();
  bool _isMicPushed = false;

  bool hasFile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _isMicPushed ? voiceRecordStop() : voiceRecordStart();
          setState(() {
            
          });
        },
        label: Text('Record'),
        icon: Icon(Icons.mic),
        foregroundColor: Colors.black,
        backgroundColor: _isMicPushed ? Colors.pink : Colors.white,
      ),
    
    );
  }

  voiceRecordStart() {
      _isRecording ? null : _start();
      _isMicPushed = true;
   
  }

  voiceRecordStop(){
      _isRecording ? _stop() : null;
      _isMicPushed = false;
  }

  String audioPath;
  
  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
     
        io.Directory appDocDirectory =
            await getApplicationDocumentsDirectory();
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

  _search() async{
    print("Search recording file : " + audioPath);
    File file = widget.localFileSystem.file(audioPath);
    if(file.exists() != null) {
        hasFile = true;
    }
    else hasFile = false;
  }
}