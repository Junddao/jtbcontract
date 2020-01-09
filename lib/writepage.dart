import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:jtbcontract/data/approvalCondition.dart';
import 'package:jtbcontract/data/contactUserInfo.dart';
import 'package:jtbcontract/getContactsPage.dart';
import 'package:jtbcontract/getFriendPage.dart';
import 'package:sms_maintained/sms.dart';

import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:volume/volume.dart';
import 'data/tabstates.dart';
import 'data/userinfo.dart';


class WritePage extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  WritePage({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final DatabaseReference database = FirebaseDatabase.instance.reference();
  final String appName = 'https://play.google.com/store/apps/details?id=com.jtbcompany.jtbcontract';

  String myPhoneNumber;
  String myName;

  Recording _recording = new Recording();
  AudioPlayer audioPlayer = AudioPlayer();

  Random random = new Random();
  TextEditingController _controller = new TextEditingController();
  bool _isRecording = false; // 녹음 파일 유무 확인
  bool _isPlaying = false;
  bool _hasRecFile = false;
  bool hasFile = false;
  int fileNum = 0;
  io.Directory appDocDirectory;
  
  ContactUserInfo contactUserInfo;
  String audioPath;
  List liRecFiles = new List();

  StreamSubscription _playerCompleteSubscription;

  @override
  void initState() {
    

    super.initState();

    myPhoneNumber = Provider.of<UserInfomation>(context, listen: false).details.phoneNumber;
    myName = Provider.of<UserInfomation>(context,  listen: false).details.userName;
    initPlatformState();
  }

  Future<void> initPlatformState() async{
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    _playerCompleteSubscription = audioPlayer.onPlayerCompletion.listen((msg){
      _onComplete();
      setState(() {});
    });
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 10,
              child: CircleAvatar(
                radius: 36,
                backgroundColor: _isRecording ? Colors.white : Colors.black,
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: _isRecording ? Colors.pink[200] : Colors.white,
                  child: IconButton(
                    icon: _hasRecFile
                        ? (_isPlaying ? Icon(Icons.stop) : Icon(Icons.play_arrow))
                        : Icon(Icons.mic),
                    color: _isRecording ? Colors.white : Colors.black,
                    iconSize: 40,
                    alignment: Alignment.center,
                    onPressed: () {
                      if (_hasRecFile) {
                        _isPlaying ? _stopPlayRec() : _playRec();
                      } else {
                        _isRecording ? voiceRecordStop() : voiceRecordStart();
                      }
                    },
                  ),
                  
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      //color: Colors.white,
                      padding: EdgeInsets.only(left: 20, bottom: 20),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.refresh),
                          Padding(
                            padding: EdgeInsets.all(5),
                          ),
                          Text("다시 녹음하기"),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          _deleteRec();
                        });
                      },
                    ),
                  ),
                
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      //color: Colors.white,
                      padding: EdgeInsets.only(right: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(Icons.send),
                          Padding(
                            padding: EdgeInsets.all(5),
                          ),
                          Text("보내기"),
                        ],
                      ),
                      onPressed: () {
                        if (_hasRecFile) {
                          _createAlertDialog(context);
                          
                        } else {
                          SnackBar alertSnackbar = SnackBar(
                            content: Text('Recording First.'),
                          );
                          Scaffold.of(context).showSnackBar(alertSnackbar);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _createAlertDialog(BuildContext context) async{
    try{
      contactUserInfo = new ContactUserInfo();

      await createAlertDialog(context);
      
      String maker = contactUserInfo.name;
      if(contactUserInfo.name.isEmpty) maker = contactUserInfo.phoneNumber;
      
      if(contactUserInfo.phoneNumber != null){
        Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(maker + '님께 요청 메세지를 발송했습니다.')));
        print(contactUserInfo.phoneNumber);
      }
    }
    catch(Exception){
      print('phoneNumber is null');
    }
    
  }

  voiceRecordStart() {
    _isRecording ? null : _start();
    // _isMicPushed = true;
  }

  voiceRecordStop() {
    _isRecording ? _stop() : null;
    // _isMicPushed = false;
  }

  
  _playRec() async {
    print("Search recording file : " + audioPath);

    try {
      io.File fiRec = io.File(audioPath);
      if (fiRec.existsSync()) {
        int result = await audioPlayer.play(audioPath, isLocal: true);
        if (result == 1) {
          _isPlaying = true;
          print("Success");
        } else {
          print("Fail");
        }
        setState(() {});
      }
    } catch (Exception) {}
  }

  _stopPlayRec() async {
    print("Search recording file : " + audioPath);

    try {
      int result = await audioPlayer.stop();
      if (result == 1) {
        _isPlaying = false;
        print("Success");
      } else {
        print("Fail");
      }
      setState(() {});
    } catch (Exception) {}
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
      if (liRecFiles.length > 0) {
        _hasRecFile = true;
      } else {
        _hasRecFile = false;
      }
    } catch (Exception) {}
  }

  _deleteRec() async {
    print("Delete recording dir : " + appDocDirectory.path);

    try {
      String directory = appDocDirectory.path;
      io.Directory diRec = io.Directory("$directory/");
      if (diRec.existsSync()) {
        diRec.deleteSync(recursive: true);
        _hasRecFile = false;
      }
    } catch (Exception) {}
  }

 
    // FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://jtbcontract.appspot.com');
  Future _uploadFile() async {
    File file = widget.localFileSystem.file(audioPath);
    
   
    String friendNumber = contactUserInfo.phoneNumber;
    String freindName = contactUserInfo.name;

    String savedPath =
        '/' + myPhoneNumber + '/' + friendNumber + '/' + file.basename;

    // send data to firbase database.
    // 보내고 나서는 DB에 저장해야 한다.  보낸사람 , 받는사람 (전화번호), 파일명, 승인상태
    // 승인 상태 : wait, approval, reject
    await createData(myPhoneNumber, myName, friendNumber, freindName, savedPath, file.basename, ApprovalCondition.ready);

    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(savedPath);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(
      file,
      StorageMetadata(
        contentType: 'audio/m4a',
        customMetadata: <String, String>{'file': 'audio'},
      ),
    );
    //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      print("uploaded.");
    });
  }

  Future createData(String _myNumber, String _myName, String _friendNumber, String _friendName, String _savedPath, String _fileName, String _approvalCondition) async {
    DateTime now = DateTime.now();
    String formattedDate  = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    database
        .child('Sender')
        .child(_myNumber).push()
        .set({
      'date' : formattedDate,
      'senderPhoneNumber': _myNumber,
      'senderName': _myName,
      'receiverPhoneNumber': _friendNumber,
      'receiverName': _friendName,
      'savedPath': _savedPath,
      'status': _approvalCondition,

      'content': '',
    });
    database
        .child('Receiver')
        .child(_friendNumber).push()
        .set({
      'date' : formattedDate,
      'senderPhoneNumber': _myNumber,
      'senderName': _myName,
      'receiverPhoneNumber': _friendNumber,
      'receiverName': _friendName,
      'savedPath': _savedPath,
      'status': _approvalCondition,

      'content': '',
    });
  }

  _navigateFriendsPage(BuildContext context) async {
    try{
      contactUserInfo = await Navigator.push(context, MaterialPageRoute(builder: (context) => GetFriendPage(myPhoneNumber : myPhoneNumber)));
      if(contactUserInfo.phoneNumber != null)
      {
        contactUserInfo.phoneNumber = (contactUserInfo.phoneNumber as String).replaceAll('-', '');
      }
      Navigator.of(context).pop(true);
      await _uploadFile();  // upload voice file.
    }
    catch(Exception)
    {
      print('phoneNumber is null');
    }

    // 앱상에 알람으로 알리기!
    //await _sendSMS(appName, phoneNumber);
  } 

  _navigateAndDisplaySelection(BuildContext context) async {
    int pageNumber = 0;
    contactUserInfo = await Navigator.push(context, MaterialPageRoute(builder: (context) => GetContactPage(selectedIndex: pageNumber,)));
    if(contactUserInfo.phoneNumber != null)
    {
      contactUserInfo.phoneNumber = (contactUserInfo.phoneNumber as String).replaceAll('-', '');
    }
    Navigator.of(context).pop(true);
    await _uploadFile();  // upload voice file.
    
    // SMS 발송하고 
    //await _sendSMS(appName, phoneNumber);
  } 

  Future _sendSMS(String message, String recipents) async {
    SmsSender sender = new SmsSender();
    SmsMessage _message = new SmsMessage(recipents, message);
    _message.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        print("SMS is sent!");
      } else if (state == SmsMessageState.Delivered) {
        print("SMS is delivered!");
      }
    });
    sender.sendSms(_message);
  }

  createAlertDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Column(
          // title: Text('Input Phone Number'),
          // content: TextField(
          //   controller: customController,
          // ),
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ButtonTheme(
              minWidth: 200.0,
              child: FlatButton(
                textColor: Colors.black,
                color: Colors.red[200],
                child: Text('연락처'),
                onPressed: () {
                  
                  _navigateAndDisplaySelection(context);
                  
                },
              ),
            ),
            ButtonTheme(
              minWidth: 200.0,
              child: FlatButton(
                textColor: Colors.black,
                color: Colors.yellow,
                child: Text('JTB 등록친구'),
                onPressed: () {
                  _navigateFriendsPage(context);
                },
              ),
            ),
          ],

        );
      }
    );
  }

  // change play status after play audio.
  void _onComplete() {
      setState(() => _isPlaying = false);
    }
}
