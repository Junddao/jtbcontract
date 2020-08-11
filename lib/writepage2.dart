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
import 'package:flutter_sms/flutter_sms.dart';
import 'package:marquee_widget/marquee_widget.dart';


import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:volume/volume.dart';
import 'data/userinfo.dart';


class WritePage2 extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  WritePage2({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage2> {
  final DatabaseReference database = FirebaseDatabase.instance.reference();
  final String appName = 'https://play.google.com/store/apps/details?id=com.jtbcompany.jtbcontract';

  String myPhoneNumber;
  String myName;
  String contents;


  Random random = new Random();
  TextEditingController _textController = new TextEditingController();

  ContactUserInfo contactUserInfo;

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
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  padding: EdgeInsets.all(20),
                  child : Text(' 상대방 동의시 증거로 효력 있음.  '),
                  // child: Marquee(
                  //   // child : Text('## 한국 민법에서는 별도의 형식을 요구하지 않고, 당사자간의 약정(합의)만으로 계약의 성립을 인정하는 낙성 불요식 계약 원칙을 따르고 있습니다. 계약 당사자가 계약 내용에 대해서 동의했다는 사실을 증명할 수 있으면 그 형태가 무엇이든 법적 효력이 인정됩니다. ##'),
                    
                  //   animationDuration: Duration(seconds: 20),
                  //   pauseDuration: Duration(milliseconds: 1000),
                  //   directionMarguee: DirectionMarguee.oneDirection,
                    
                  // ),
                ),
                
                
                Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          height: 200,
                          child: new TextField(
                            controller: _textController,
                            onSubmitted: _handleSubmitted,
                            maxLines: 10,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '내용을 작성하세요. '
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(
              height: 40,
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
                          Text("다시 작성하기"),
                        ],
                      ),
                      onPressed: () => _handleSubmitted(_textController.text),
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
                        if (_textController.text.length > 0) {
                          _createAlertDialog(context);
                          // _handleSubmitted(_textController.text);
                        } else {
                          SnackBar alertSnackbar = SnackBar(
                            content: Text('내용을 작성하세요.'),
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
  void _handleSubmitted(String text) {
    _textController.clear(); 
  }

  _createAlertDialog(BuildContext context) async{
    try{
      contactUserInfo = new ContactUserInfo();

      await createAlertDialog(context);

      // //보내고 난 후에는 내용 지우기
      _textController.text = '';
    }
    catch(Exception){
      print('phoneNumber is null');
    }
    
  }

  Future createSnackBar() async{
    String maker = contactUserInfo.name;
      if(contactUserInfo.name.isEmpty) maker = contactUserInfo.phoneNumber;
      
      if(contactUserInfo.phoneNumber != null){
        Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(maker + '님께 요청 메세지를 발송했습니다.')));
        print(contactUserInfo.phoneNumber);
      }
  }

 
    // FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://jtbcontract.appspot.com');
  Future _uploadFile() async {

    String friendNumber = contactUserInfo.phoneNumber;
    String freindName = contactUserInfo.name;

 

    // send data to firbase database.
    // 보내고 나서는 DB에 저장해야 한다.  보낸사람 , 받는사람 (전화번호), 파일명, 승인상태
    // 승인 상태 : wait, approval, reject
    await createData(myPhoneNumber, myName, friendNumber, freindName, '', '', ApprovalCondition.ready);

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
      'contents': _textController.text,
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

      'contents': _textController.text,
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
    await _sendSMS(appName, contactUserInfo.phoneNumber, myName);
    _handleSubmitted(_textController.text);
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
    await _sendSMS(appName, contactUserInfo.phoneNumber, myName);
  } 

  Future<void> _sendSMS(String appName, String number, String nyName) async {
    String message = appName + "\n\n" + '준태봉약속 앱에서 ' + nyName + '님의 승인 요청이 있습니다..';
    List<String> recipents = [number];
    String _result = await FlutterSms
            .sendSMS(message: message, recipients: recipents)
            .catchError((onError) {
          print(onError);
        });
    print(_result);
  }

  Future createAlertDialog(BuildContext context) async {
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

}
