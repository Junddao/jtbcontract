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
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;

import 'package:synchronized/synchronized.dart';

enum MyDialogAction {
  yes,
  no,
  wait,
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
  ProgressDialog pr;

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
  List<DBData> friendSentData = [];
  List<DBData> friendReceivedData = [];

  String myPhoneNumber;

  var contacts;
  String selectedPhoneNumber;

  TabController ctr;

  var lock = new Lock();

  @override
  void initState() {
    myPhoneNumber =
        Provider.of<UserInfomation>(context, listen: false).details.phoneNumber;
    ctr = new TabController(vsync: this, length: 2);

    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference itemSenderRef =
        firebaseDatabase.reference().child('Sender').child(myPhoneNumber);
    itemSenderRef.onChildChanged.listen(_onEntryChanged);
    itemSenderRef.onChildAdded.listen(_onEntryAdded);

    getStatusStream(itemSenderRef, _updatedStatus)
        .then((StreamSubscription s) => _subscriptionStatus = s);

    super.initState();
  }

  Future<StreamSubscription<Event>> getStatusStream(
      DatabaseReference _itemRef, _updatedStatus) async {
    StreamSubscription<Event> _subscription;

    try {
      await _itemRef.once().then((DataSnapshot snap) {
        var keys = snap.value.keys;
        for (var key in keys) {
          _subscription =
              _itemRef.child(key).child('status').onValue.listen((Event event) {
            String status = event.snapshot.value as String;
            if (status == null) {
              status = '';
            }
          });
        }
      });
      setState(() {
        // lock.synchronized(getMySentDBData);
        // lock.synchronized(getMyReceivedDBData);
      });
    } catch (Exception) {
      print('getStatusStream error');
    }

    return _subscription;
  }

  _updatedStatus() {
    setState(() {
      print('changed');
    });
  }

  _onEntryChanged(Event event) {
    setState(() {
      // lock.synchronized(getMySentDBData);
      // lock.synchronized(getMyReceivedDBData);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      // lock.synchronized(getMySentDBData);
      // lock.synchronized(getMyReceivedDBData);
    });
  }

  @override
  void dispose() {
    ctr.dispose();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }

  Future<List<DBData>> getMySentDBData() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try{
      sentData.clear();
      await ref
          .child('Sender')
          .child(myPhoneNumber)
          .once()
          .then((DataSnapshot snap) {
        var keys = snap.value.keys;
        var data = snap.value;
        for (var key in keys) {
          DBData d = new DBData(
              key,
              data[key]['date'],
              data[key]['senderPhoneNumber'],
              data[key]['senderName'],
              data[key]['receiverPhoneNumber'],
              data[key]['receiverName'],
              data[key]['savedPath'],
              data[key]['status'],
              data[key]['contents']);
          if (d.senderPhoneNumber == myPhoneNumber) {
            sentData.add(d);
          }
        }
      });
    }
    catch(Exception) {
      print('sent db error');
    }
    
    return sentData;
  }

  Future<List<DBData>> getMyReceivedDBData() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();

    try{
      receivedData.clear();
          await ref
              .child('Receiver')
              .child(myPhoneNumber)
              .once()
              .then((DataSnapshot snap) {
            var keys = snap.value.keys;
            var data = snap.value;
            for (var key in keys) {
              DBData d = new DBData(
                  key,
                  data[key]['date'],
                  data[key]['senderPhoneNumber'],
                  data[key]['senderName'],
                  data[key]['receiverPhoneNumber'],
                  data[key]['receiverName'],
                  data[key]['savedPath'],
                  data[key]['status'],
                  data[key]['contents']);
              if (d.receiverPhoneNumber == myPhoneNumber) {
                receivedData.add(d);
              }
            }
          });
    }
    catch(Exception) {
      print('received db error');
    }
    return receivedData;
    
  }

  Future getFriendDBData(String friendPhoneNumber) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    friendSentData.clear();
    friendReceivedData.clear();
    try {
      await ref
          .child('Sender')
          .child(friendPhoneNumber)
          .once()
          .then((DataSnapshot snap) {
        var keys = snap.value.keys;
        var data = snap.value;
        for (var key in keys) {
          DBData d = new DBData(
              key,
              data[key]['date'],
              data[key]['senderPhoneNumber'],
              data[key]['senderName'],
              data[key]['receiverPhoneNumber'],
              data[key]['receiverName'],
              data[key]['savedPath'],
              data[key]['status'],
              data[key]['contents']);
          if (d.senderPhoneNumber == friendPhoneNumber) {
            friendSentData.add(d);
          }
        }
      });
    } catch (Exception) {
      print('error');
    }
    try {
      await ref
          .child('Receiver')
          .child(friendPhoneNumber)
          .once()
          .then((DataSnapshot snap) {
        var keys = snap.value.keys;
        var data = snap.value;
        for (var key in keys) {
          DBData d = new DBData(
              key,
              data[key]['date'],
              data[key]['senderPhoneNumber'],
              data[key]['senderName'],
              data[key]['receiverPhoneNumber'],
              data[key]['receiverName'],
              data[key]['savedPath'],
              data[key]['status'],
              data[key]['contents']);
          if (d.receiverPhoneNumber == friendPhoneNumber) {
            friendReceivedData.add(d);
          }
        }
        setState(() {
          print('length : ${friendSentData.length}');
          print('length : ${friendReceivedData.length}');
        });
      });
    } catch (Exception) {
      print('error');
    }
  }

  Future setStatusOfDBData(MyDialogAction myDialogAction, DBData dbData) async {
    await setStatusOfMyDBData(myDialogAction, dbData);
    await setStatusOfFriendsDBData(myDialogAction, dbData);
    setState(() {
      // lock.synchronized(getMySentDBData);
      // lock.synchronized(getMyReceivedDBData);
    });
  }

  Future setStatusOfMyDBData(
      MyDialogAction myDialogAction, DBData dbData) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();

    try {
      if (myDialogAction == MyDialogAction.yes) {
        await ref
            .child('Receiver')
            .child(myPhoneNumber)
            .child(dbData.key)
            .update({'status': '승인'});
      } else
        await ref
            .child('Receiver')
            .child(myPhoneNumber)
            .child(dbData.key)
            .update({'status': '거절'});
    } catch (Exception) {
      print('update error');
    }
  }

  Future setStatusOfFriendsDBData(
      MyDialogAction myDialogAction, DBData dbData) async {
    try {
      String modifyKey;
      for (DBData db in friendSentData) {
        if (db.savedPath == dbData.savedPath) {
          modifyKey = db.key;
        }
      }

      DatabaseReference ref = FirebaseDatabase.instance.reference();
      if (myDialogAction == MyDialogAction.yes) {
        await ref
            .child('Sender')
            .child(dbData.senderPhoneNumber)
            .child(modifyKey)
            .update({'status': '승인'});
      } else {
        await ref
            .child('Sender')
            .child(dbData.senderPhoneNumber)
            .child(modifyKey)
            .update({'status': '거절'});
      }
    } catch (Exception) {
      print('update error');
    }
  }

  deleteDBData(int index) async {
    String removeKey = sentData[index].key;
    String savedPath = sentData[index].savedPath;
    String friendPhoneNumber = sentData[index].receiverPhoneNumber;

    // 친구 DB 정보 가져와서
    await getFriendDBData(friendPhoneNumber);
    // 친구 DB 지우고,
    deleteFriendReceivedDBData(savedPath, friendPhoneNumber);

    // 내 보낸 DB 지우고,
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    await ref
        .child('Sender')
        .child(myPhoneNumber)
        .child(removeKey)
        .remove()
        .then((_) {
      print('delete $removeKey');
      setState(() {
        // lock.synchronized(getMySentDBData);
        // lock.synchronized(getMyReceivedDBData);
      });
    });
  }

  // 친구 받은 dB 삭제는 savedpath 로 찾자.
  deleteFriendReceivedDBData(String savedPath, String freindPhoneNumber) async {
    String removeKey;
    for (DBData db in friendReceivedData) {
      if (db.savedPath == savedPath) {
        removeKey = db.key;
      }
    }

    DatabaseReference ref = FirebaseDatabase.instance.reference();
    await ref
        .child('Receiver')
        .child(freindPhoneNumber)
        .child(removeKey)
        .remove()
        .then((_) {
      print('delete $removeKey');
      setState(() {
        // lock.synchronized(getMySentDBData);
        // lock.synchronized(getMyReceivedDBData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _playerCompleteSubscription = audioPlayer.onPlayerCompletion.listen((msg) {
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
                text: '받은파일',
              ),
              new Tab(
                icon: Icon(Icons.send),
                text: '보낸파일',
              ),
            ],
          ),
        ),
      ),
      body: Container(
        child: TabBarView(
          controller: ctr,
          children: <Widget>[
            receivedTabPage(),
            sentTabPage(),
          ],
        ),
      ),
    );
  }

  receivedTabPage() {
    return FutureBuilder(
        future: lock.synchronized(getMyReceivedDBData),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
              break;
            case ConnectionState.done:
              if (snapshot.hasData == null) {
                return Container();
              }
              break;
            case ConnectionState.none:
              return Container(
                child: Center(
                  child: Text('none'),
                ),
              );
              break;
            case ConnectionState.active:
              return Container(
                child: Center(
                  child: Text('active'),
                ),
              );
              break;
          }
          return Container(
            padding: EdgeInsets.all(20.0),
            child: receivedData.length == 0
                ? displayedPage(false)
                : new ListView.builder(
                    itemCount: receivedData.length,
                    itemBuilder: (_, index) {
                      DBData dbData = new DBData(
                          receivedData[index].key,
                          receivedData[index].date,
                          receivedData[index].senderPhoneNumber,
                          receivedData[index].senderName,
                          receivedData[index].receiverPhoneNumber,
                          receivedData[index].receiverName,
                          receivedData[index].savedPath,
                          receivedData[index].status,
                          receivedData[index].contents);
                      return ReceivedUI(dbData, index);
                    }),
          );
        });
  }

  sentTabPage() {
    return FutureBuilder(
        future: lock.synchronized(getMySentDBData),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
              break;
            case ConnectionState.done:
              if (snapshot.hasData == null) {
                return Container();
              }
              break;
            case ConnectionState.none:
              return Container(
                child: Center(
                  child: Text('none'),
                ),
              );
              break;
            case ConnectionState.active:
              return Container(
                child: Center(
                  child: Text('active'),
                ),
              );
              break;
          }
          return new Container(
            padding: EdgeInsets.all(20.0),
            child: sentData.length == 0
                ? displayedPage(false)
                : new ListView.builder(
                    itemCount: sentData.length,
                    itemBuilder: (_, index) {
                      DBData dbData = new DBData(
                          sentData[index].key,
                          sentData[index].date,
                          sentData[index].senderPhoneNumber,
                          sentData[index].senderName,
                          sentData[index].receiverPhoneNumber,
                          sentData[index].receiverName,
                          sentData[index].savedPath,
                          sentData[index].status,
                          sentData[index].contents);
                      return SentUI(dbData, index);
                    }),
          );
        });
  }

  Container displayedPage(bool hasFile) {
    if (hasFile == false) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('비었음!'),
          ],
        ),
      );
    }
  }

  displayProgressBar(BuildContext context, DBData dbData) async {
    // 재생중이면 그냥 정지하고 빠져나가게 하기
    if (_isPlaying == true) {
      _stopPlayRec();
      return;
    } else {
      pr = new ProgressDialog(context);
      pr.style(message: 'Please wait...');

      pr.show();
      _downloadFile(context, dbData).then((onValue) {
        pr.hide();
      });
    }
  }

  Future _downloadFile(BuildContext context, DBData dbData) async {
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
    final StorageFileDownloadTask task =
        firebaseStorageRef.writeToFile(tempFile);
    final int byteCount = (await task.future).totalByteCount;
    var bodyBytes = downloadData.bodyBytes;
    final String name = await firebaseStorageRef.getName();
    final String path = await firebaseStorageRef.getPath();
    print(
      'Success!\nDownloaded $name \nUrl: $url'
      '\npath: $path \nBytes Count :: $byteCount',
    );

    _isPlaying == false ? _playRec() : _stopPlayRec();

    //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      print("Downloaded.");
    });
  }

  Future _deleteFile(DBData dbData, int index) async {
    // 폴더 파일 지우고,

    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(dbData.savedPath);
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

  _createAlertDialog(BuildContext context, DBData dbData) async {
    if (dbData.status == ApprovalCondition.ready) {
      await showAlert(context, dbData);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: new Text('이미 결정한 파일입니다. 상대방에게 삭제 요청을 하세요.'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('ok'),
                )
              ],
            );
          });
    }
  }

  Future<void> showAlert(BuildContext context, DBData dbData) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: new Text(
              '음성 파일을 듣고 동의 여부를 선택하세요.',
              style: new TextStyle(fontSize: 20.0),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  _dialogResult(context, MyDialogAction.yes, dbData);
                },
                child: Text('동의'),
              ),
              new FlatButton(
                onPressed: () {
                  _dialogResult(context, MyDialogAction.no, dbData);
                },
                child: Text('거절'),
              ),
            ],
          );
        });
  }

  _dialogResult(
      BuildContext context, MyDialogAction value, DBData dbData) async {
    await setStatusOfDBData(value, dbData);
    Navigator.of(context).pop(true);
  }

  Widget SentUI(DBData dbData, int index) {
    Color backColor;

    if (dbData.status == ApprovalCondition.ready) {
      backColor = Colors.grey;
    }
    if (dbData.status == ApprovalCondition.approval) {
      backColor = Colors.blue;
    }
    if (dbData.status == ApprovalCondition.reject) {
      backColor = Colors.red;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 20,
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
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            dbData.receiverName,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          new Text(
                            ' (' + dbData.receiverPhoneNumber + ')' + '\n',
                          ),
                        ],
                      ),

                      //new Text('생성일 : '),
                      new Text(
                        dbData.date.toString(),
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: new Container(
                child: sentData.isNotEmpty
                    ? IconButton(
                        icon: sentDataSelectPlayIcon(index),
                        onPressed: () {
                          sentData[index].isSelected = true;
                          displayProgressBar(context, dbData);
                        },
                      )
                    : null,
              ),
            ),
            Expanded(
              flex: 1,
              child: new Container(
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
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
      backColor = Colors.blue;
    }
    if (dbData.status == ApprovalCondition.reject) {
      backColor = Colors.red;
    }

    return GestureDetector(
      onTap: () async {
        await getFriendDBData(dbData.senderPhoneNumber);
        _createAlertDialog(context, dbData);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 20,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: new CircleAvatar(
                    backgroundColor: backColor,
                    child: Text(dbData.status),
                    foregroundColor: Colors.white,
                    minRadius: 40,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: new Container(
                    child: new Padding(
                  padding: EdgeInsets.all(3),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            dbData.senderName,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          new Text(
                            ' (' + dbData.senderPhoneNumber + ')' + '\n',
                          ),
                        ],
                      ),
                      new Text(
                        dbData.date.toString(),
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                )),
              ),
              Expanded(
                flex: 1,
                child: new Container(
                  child: receivedData.isNotEmpty
                      ? IconButton(
                          icon: receivedDataSelectPlayIcon(index),
                          onPressed: () {
                            receivedData[index].isSelected = true;
                            displayProgressBar(context, dbData);
                          },
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Icon sentDataSelectPlayIcon(int index) {
    if (sentData[index].isSelected) {
      sentData[index].isSelected = false;
      if (_isPlaying == false) {
        return Icon(Icons.play_arrow);
      } else {
        return Icon(Icons.stop);
      }
    } else {
      return Icon(Icons.play_arrow);
    }
  }

  Icon receivedDataSelectPlayIcon(int index) {
    if (receivedData[index].isSelected) {
      receivedData[index].isSelected = false;
      if (_isPlaying == false) {
        return Icon(Icons.play_arrow);
      } else {
        return Icon(Icons.stop);
      }
    } else {
      return Icon(Icons.play_arrow);
    }
  }

  // change play status after play audio.
  void _onComplete() {
    setState(() => _isPlaying = false);
  }
}
