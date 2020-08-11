import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jtbcontract/data/contactUserInfo.dart';
import 'package:jtbcontract/data/dbData.dart';
import 'package:synchronized/synchronized.dart';

class GetFriendPage extends StatefulWidget {
  final String myPhoneNumber;
  const GetFriendPage({Key key, this.myPhoneNumber}) : super(key: key);

  @override
  _GetFriendPageState createState() => _GetFriendPageState();
}

class _GetFriendPageState extends State<GetFriendPage> {
  List<DBContacts> liContactUserInfo = [];
  ContactUserInfo contactUserInfo = new ContactUserInfo();

  var lock = new Lock();

  @override
  void initState() {
    //getDBData();
    super.initState();
  }

  Future<List<DBContacts>> getDBData() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    liContactUserInfo.clear();
    try {
      await ref
          .child('Contact')
          .child(widget.myPhoneNumber)
          .once()
          .then((DataSnapshot snap) {
        var keys = snap.value.keys;
        var data = snap.value;
        for (var key in keys) {
          DBContacts d = new DBContacts(
            key,
            data[key]['name'],
            data[key]['phoneNumber'],
          );
          liContactUserInfo.add(d);
        }
      });
    } catch (Exception) {
      print('error');
    }
    return liContactUserInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('jtb 친구목록'),
          backgroundColor: Colors.black,
        ),
        body: FutureBuilder(
            future: lock.synchronized(getDBData),
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
                child: liContactUserInfo != null
                    ? ListView.builder(
                        itemCount: liContactUserInfo.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          DBContacts dbContacts =
                              liContactUserInfo.elementAt(index);
                          return ListTile(
                            onTap: () {
                              getPhoneNumber(dbContacts);
                              getName(dbContacts);
                              Navigator.pop(context, contactUserInfo);
                            },
                            leading: (dbContacts.name != null &&
                                    dbContacts.name.length > 0)
                                ? CircleAvatar(
                                    child:
                                        Text(dbContacts.name.substring(0, 1)),
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  )
                                : CircleAvatar(
                                    child: Text('-'),
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                            title: Text(dbContacts.name ?? ""),
                            subtitle: Text(dbContacts.phoneNumber ?? ""),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              );
            }));
  }

  getPhoneNumber(DBContacts dbContacts) {
    contactUserInfo.phoneNumber = dbContacts.phoneNumber;
  }

  getName(DBContacts dbContacts) {
    contactUserInfo.name = dbContacts.name;
  }
}
