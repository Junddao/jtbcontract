import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jtbcontract/data/approvalCondition.dart';
import 'package:jtbcontract/data/dbData.dart';
import 'package:jtbcontract/data/userinfo.dart';
import 'package:jtbcontract/service/myContactsService.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
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
      for (var key in keys) {
        DBData d = new DBData(data[key]['sender'], data[key]['receiver'],
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

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ));
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
                    receivedData[index].contents);
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
                    sentData[index].contents);
              }),
    );
  }

  Widget UI(String _sender, String _receiver, String _savedPath, String _status,
      String _contents) {

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


    
    return new Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 10,

        //color: Colors.pink,

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
            ],
          ),
        ));
  }
  
}
