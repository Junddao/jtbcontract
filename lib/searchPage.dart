import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jtbcontract/data/approvalCondition.dart';
import 'package:jtbcontract/data/dbData.dart';
import 'package:jtbcontract/data/userinfo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;

class SearchPage extends StatefulWidget {

  final LocalFileSystem localFileSystem;
  SearchPage({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
    
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {

  // 재생완료 이벤트 구독
  StreamSubscription _playerCompleteSubscription;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  
  // 다운받은 파일 재생용 변수
  io.Directory appDocDirectory;
  File tempFile;
  AudioPlayer audioPlayer = AudioPlayer();

  bool _isPlaying = false;

  List<DBData> allData = [];
  List<DBData> sentData = [];
  List<DBData> receivedData = [];
  String myPhoneNumber;

  List<Contact> _contacts;
  var contacts;
  String selectedPhoneNumber;

  TabController ctr;


  @override
  void initState() {
    getDBData();
    ctr = new TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  @override
  void dispose() {
    ctr.dispose();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }

  getDBData() {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    myPhoneNumber =
        Provider.of<UserInfomation>(context, listen: false).details.phoneNumber;
    ref.child(myPhoneNumber).once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      allData.clear();
      sentData.clear();
      receivedData.clear();
      for (var key in keys) {
        DBData d = new DBData(key, data[key]['sender'], data[key]['receiver'],
            data[key]['savedPath'], data[key]['status'], data[key]['contents']);
        allData.add(d);
        if (d.sender == myPhoneNumber) {
          sentData.add(d);
        }
        if (d.receiver == myPhoneNumber) {
          receivedData.add(d);
        }
      }
      setState(() {
        print('length : ${allData.length}');
      });
    });
  }

  deleteDBData(int index) async{
    String removeKey = sentData[index].key;
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    await ref.child(myPhoneNumber).child(removeKey).remove().then((_)
    {
      print('delete $removeKey');
      setState(() {
        getDBData();
      });
      
    });
  }

  @override
  Widget build(BuildContext context) {
   
    _playerCompleteSubscription = audioPlayer.onPlayerCompletion.listen((msg){
      _onComplete();
      setState(() {});
    });

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: new TabBar(
            indicatorColor: Colors.pink,
            labelColor: Colors.black,
            controller: ctr,
            tabs: <Tab>[
              new Tab(
                icon: Icon(Icons.receipt),
                text: 'received',
              ),
              new Tab(
                icon: Icon(Icons.send),
                text: 'sent',
              ),
            ],
          ),
        ),
      ),
      body: new TabBarView(
        controller: ctr,
        children: <Widget>[
          receivedTabPage(),
          sentTabPage(),
        ],
      )
    );
  }

  receivedTabPage() {
    return new Container(
      padding: EdgeInsets.all(20.0),
      child: receivedData.length == 0
          ? new Text('no Data is Available')
          : new ListView.builder(
              itemCount: receivedData.length,
              itemBuilder: (_, index) {
                return UI(
                    receivedData[index].sender,
                    receivedData[index].receiver,
                    receivedData[index].savedPath,
                    receivedData[index].status,
                    receivedData[index].contents,
                    index);
              }),
    );
  }

  sentTabPage() {
    return new Container(
      padding: EdgeInsets.all(20.0),
      child: sentData.length == 0
          ? new Text('no Data is Available')
          : new ListView.builder(
              itemCount: sentData.length,
              itemBuilder: (_, index) {
                return UI(
                    sentData[index].sender,
                    sentData[index].receiver,
                    sentData[index].savedPath,
                    sentData[index].status,
                    sentData[index].contents,
                    index);
              }),
    );
  }

  Future _downloadFile(String _savedPath) async {
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(_savedPath);
            
    final String url = await firebaseStorageRef.getDownloadURL();
    final http.Response downloadData = await http.get(url);
    appDocDirectory = await getApplicationDocumentsDirectory();

    tempFile = widget.localFileSystem.file('${appDocDirectory.path}/temp.m4a');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    final StorageFileDownloadTask task = firebaseStorageRef.writeToFile(tempFile);
    final int byteCount = (await task.future).totalByteCount; 
    var bodyBytes = downloadData.bodyBytes;
    final String name = await firebaseStorageRef.getName();
    final String path = await firebaseStorageRef.getPath();
    print(
      'Success!\nDownloaded $name \nUrl: $url'
      '\npath: $path \nBytes Count :: $byteCount',
    );
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Image.memory(
          bodyBytes,
          fit: BoxFit.fill,
        ),
      ),
    );
    _isPlaying == false ? _playRec() : _stopPlayRec();

    //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      print("Downloaded.");
    });
  }
  
  Future _deleteFile(String _savedPath, int index) async{
    
    // 폴더 파일 지우고,
    
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(_savedPath);
    firebaseStorageRef.delete();
    
    StorageReference parent = firebaseStorageRef.getParent();
    //todo: 나중에 폴더 삭제하는 기능까지 넣어야한다....


    // DB 삭제하고 List 초기화
    deleteDBData(index);
    
            
  }


  _playRec() async {
    print("Search recording file : " + tempFile.path);

    try {
      io.File fiRec = io.File(tempFile.path);
      if (fiRec.existsSync()) {
        int result = await audioPlayer.play(tempFile.path, isLocal: true);
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
    print("Search recording file : " + tempFile.path);

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


  Widget UI(String _sender, String _receiver, String _savedPath, String _status,
      String _contents, int index) {

    Color backColor;

    if ('$_status' == ApprovalCondition.ready) {
      backColor = Colors.grey;
    }
    if ('$_status' == ApprovalCondition.approval) {
      backColor = Colors.blue;
    }
    if ('$_status' == ApprovalCondition.reject) {
      backColor = Colors.red;
    }

   return Card(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: new CircleAvatar(
                backgroundColor: backColor,
                child: Text('$_status'),
                foregroundColor: Colors.white,
                minRadius: 40,
              ),
            ),
            Expanded(
              flex: 3,
              child: new Container(
                child: new Column(
                  children: <Widget>[
                    new Text('Sender : $_sender',),
                    new Text('Receiver : $_receiver'),
                    //new Text('savedPath : $_savedPath'),
                    //new Text('status : $_status'),
                    //new Text('Sender : $_contents'),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: new Container(
                child: IconButton(
                  icon: selectPlayIcon(index), 
                  onPressed: (){
                    sentData[index].isSelected = true;
                    _downloadFile(_savedPath);
                  },
                ),
              ),
            ),
             Expanded(
              flex: 1,
              child: new Container(
                child: IconButton(
                  icon: Icon(Icons.delete), 
                  onPressed: (){
                    sentData[index].isSelected = true;
                    _deleteFile(_savedPath, index);
                  },
                ),
              ),
            ),
          ],
        ),
      )
    );

        
  }

  Icon selectPlayIcon(int index)
  {
    if(sentData[index].isSelected)
    {
      if(_isPlaying == false){
        return Icon(Icons.play_arrow);
      }
      else{
        sentData[index].isSelected = false;
        return Icon(Icons.stop);
      }
    }
    else{
      return Icon(Icons.play_arrow);
    } 
  }

  

  // change play status after play audio.
  void _onComplete() {
      setState(() => _isPlaying = false);
    }
}
