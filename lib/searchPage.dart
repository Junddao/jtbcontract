import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jtbcontract/data/approvalCondition.dart';
import 'package:jtbcontract/data/dbData.dart';
import 'package:jtbcontract/data/userinfo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import 'package:firebase_messaging/firebase_messaging.dart';

enum MyDialogAction{
      yes,
      no,
}

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
  StreamSubscription _subscriptionStatus;
 
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  
  // 다운받은 파일 재생용 변수
  io.Directory appDocDirectory;
  File tempFile;
  AudioPlayer audioPlayer = AudioPlayer();

  bool _isPlaying = false;

  List<DBData> allData = [];
  List<DBData> sentData = [];
  List<DBData> receivedData = [];

  List<DBData> friendAllData = [];
  List<DBData> friendReceivedData = [];
  String myPhoneNumber;

  List<Contact> _contacts;
  var contacts;
  String selectedPhoneNumber;

  TabController ctr;


  @override
  void initState() {
    getDBData();
    ctr = new TabController(vsync: this, length: 2);
    
    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference itemRef = firebaseDatabase.reference().child(myPhoneNumber);
    itemRef.onChildChanged.listen(_onEntryChanged);
    itemRef.onChildAdded.listen(_onEntryAdded);

    getStatusStream(itemRef, _updatedStatus).then((StreamSubscription s) => _subscriptionStatus = s);

    super.initState();
  }

  Future<StreamSubscription> getStatusStream(DatabaseReference _itemRef, _updatedStatus) async{
    StreamSubscription<Event> _subscription;
    _itemRef.once().then((DataSnapshot snap){
      var keys = snap.value.keys;
      for(var key in keys){
        _subscription = _itemRef.child(key).child('status').onValue.listen((Event event){
          String status = event.snapshot.value as String;
          if(status == null) { 
            status = '';
          }
        });
      }
    });

    return _subscription;
  }

  _updatedStatus() {
    setState(() {
      print('changed');
    });
  }

  _onEntryChanged(Event event){
    getDBData();
    setState(() {
      
    });
  }

  _onEntryAdded(Event event){
    getDBData();
    setState(() {
      
    });
  }

  @override
  @override
  void dispose() {
    ctr.dispose();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }

  getDBData() async {
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

  setStatusOfDBData(MyDialogAction myDialogAction, DBData dbData) async {
    setStatusOfMyDBData(myDialogAction, dbData);
    setStatusOfFriendsDBData(myDialogAction, dbData);
  }
  
  setStatusOfMyDBData(MyDialogAction myDialogAction, DBData dbData) async{
    DatabaseReference ref = FirebaseDatabase.instance.reference();

    if(myDialogAction == MyDialogAction.yes){
      ref.child(myPhoneNumber).child(dbData.key).child('status').set('승인');
    }
    else
      ref.child(myPhoneNumber).child(dbData.key).child('status').set('거절');
    setState(() { });
  }

  setStatusOfFriendsDBData(MyDialogAction myDialogAction, DBData dbData) async{
    String modifyKey;
    for(DBData db in friendReceivedData){
      if(db.savedPath == dbData.savedPath){
        modifyKey = db.key;
      }
    }

    DatabaseReference ref = FirebaseDatabase.instance.reference();
    if(myDialogAction == MyDialogAction.yes){
      ref.child(dbData.receiver).child(modifyKey).child('status').set('승인');
    }
    else{
      ref.child(dbData.receiver).child(modifyKey).child('status').set('거절');
    }

    setState(() {
      getDBData();
    });
   
  }

  getFriendDBData(String friendPhoneNumber) async{
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    
    await ref.child(friendPhoneNumber).once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      friendAllData.clear();
      friendReceivedData.clear();
      for (var key in keys) {
        DBData d = new DBData(key, data[key]['sender'], data[key]['receiver'],
            data[key]['savedPath'], data[key]['status'], data[key]['contents']);
        friendAllData.add(d);
        
        if (d.receiver == friendPhoneNumber) {
          friendReceivedData.add(d);
        }
      }
      setState(() {
        print('length : ${allData.length}');
      });
    });
  }

  deleteDBData(int index) async{
    String removeKey = sentData[index].key;
    String savedPath = sentData[index].savedPath;
    String friendPhoneNumber = sentData[index].receiver;

    // 친구 DB 정보 가져와서 
    await getFriendDBData(friendPhoneNumber);
    // 친구 DB 지우고, 
    deleteFriendReceivedDBData(savedPath, friendPhoneNumber);

    // 내 보낸 DB 지우고, 
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    await ref.child(myPhoneNumber).child(removeKey).remove().then((_)
    {
      print('delete $removeKey');
      setState(() {
        getDBData();
      });
    });
    
  }

  // 친구 받은 dB 삭제는 savedpath 로 찾자.
  deleteFriendReceivedDBData(String savedPath, String freindPhoneNumber) async{
    String removeKey;
    for(DBData db in friendReceivedData){
      if(db.savedPath == savedPath){
        removeKey = db.key;
      }
    }

    DatabaseReference ref = FirebaseDatabase.instance.reference();
    await ref.child(freindPhoneNumber).child(removeKey).remove().then((_)
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
              DBData dbData = new DBData(receivedData[index].key,
                receivedData[index].sender,
                receivedData[index].receiver,
                receivedData[index].savedPath,
                receivedData[index].status,
                receivedData[index].contents);
              return ReceivedUI(
                dbData,
                index);
            }
          ),
              
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
              DBData dbData = new DBData(sentData[index].key,
                sentData[index].sender,
                sentData[index].receiver,
                sentData[index].savedPath,
                sentData[index].status,
                sentData[index].contents);
              return SentUI(
                dbData,
                index);
            }),
    );
  }

  Future _downloadFile(DBData dbData) async {
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(dbData.savedPath);
            
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
  
  Future _deleteFile(DBData dbData, int index) async{
    
    // 폴더 파일 지우고,
    
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(dbData.savedPath);
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


  void showAlert(DBData dbData){
    AlertDialog dialog = new AlertDialog(
      content: new Text('Yes or Not', style: new TextStyle(fontSize: 30.0),),
      actions: <Widget>[
        new FlatButton(
          onPressed: (){
            _dialogResult(MyDialogAction.yes, dbData);
          }, 
          child: Text('Yes'),
        ),
        new FlatButton(
          onPressed: (){
            _dialogResult(MyDialogAction.no, dbData);
          }, 
          child: Text('No'),
        )
      ],
    );

    showDialog(context: context, child: dialog);
      
  }

  _dialogResult(MyDialogAction value, DBData dbData){

      setStatusOfDBData(value, dbData);
      Navigator.pop(context);
    
  }


  Widget SentUI(DBData dbData, int index) {

    Color backColor;

    if (dbData.status == ApprovalCondition.ready) {
      backColor = Colors.grey;
    }
    if (dbData.status == ApprovalCondition.approval) {
      backColor = Colors.blue[300];
    }
    if (dbData.status == ApprovalCondition.reject) {
      backColor = Colors.red[300];
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
                  child: Text(dbData.status),
                  foregroundColor: Colors.white,
                  minRadius: 40,
                ),
              ),
              Expanded(
                flex: 3,
                child: new Container(
                  child: new Column(
                    children: <Widget>[
                      new Text('Sender : ' + dbData.sender),
                      new Text('Receiver : ' + dbData.receiver),
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
                      _downloadFile(dbData);
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
                      _deleteFile(dbData, index);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
    );
    
  }
  
  
  Widget ReceivedUI(DBData dbData, int index) {

    Color backColor;

    if (dbData.status == ApprovalCondition.ready) {
      backColor = Colors.grey;
    }
    if (dbData.status == ApprovalCondition.approval) {
      backColor = Colors.blue[300];
    }
    if (dbData.status == ApprovalCondition.reject) {
      backColor = Colors.red[300];
    }

   return GestureDetector(
      onTap: (){
        showAlert(dbData);
        setState(() {
          
      });
      },
      child: Card(
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
                  child: Text(dbData.status),
                  foregroundColor: Colors.white,
                  minRadius: 40,
                ),
              ),
              Expanded(
                flex: 3,
                child: new Container(
                  child: new Column(
                    children: <Widget>[
                      new Text('Sender : ' + dbData.sender,),
                      new Text('Receiver : ' + dbData.receiver),
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
                      _downloadFile(dbData);
                    },
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
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
