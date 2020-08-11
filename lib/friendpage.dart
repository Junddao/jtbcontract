import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtbcontract/data/contactUserInfo.dart';
import 'package:jtbcontract/data/dbData.dart';
import 'package:jtbcontract/data/userinfo.dart';
import 'package:jtbcontract/getContactsPage.dart';
import 'package:provider/provider.dart';
import 'package:synchronized/synchronized.dart';

class FreindPage extends StatefulWidget {
  @override
  _FreindPageState createState() => _FreindPageState();
}

class _FreindPageState extends State<FreindPage> {

  ContactUserInfo contactUserInfo = new ContactUserInfo();
  List<DBContacts> liContactUserInfo = [];
  var myPhoneNumber;
  var lock = Lock();

  createDatabase() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    try{
      await ref.child('Contact').child(myPhoneNumber).push().set({
        'name' : contactUserInfo.name,
        'phoneNumber' : contactUserInfo.phoneNumber
      });

      SnackBar alertSnackbar = SnackBar(
        content: Text('추가하였습니다.'),
      );
      Scaffold.of(context).showSnackBar(alertSnackbar);
      
      setState(() { 
        lock.synchronized(getDBData);
      });
    }
    catch(Exception){
      print('create Database Error');
    }
  }

  deleteDatabase(int index) async{
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    String removeKey = liContactUserInfo[index].key;
    await ref.child('Contact').child(myPhoneNumber).child(removeKey).remove().then((_)
    {
      print('delete $removeKey');
      setState(() {
        lock.synchronized(getDBData);
      });
    });
  }
  
  getDBData() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    liContactUserInfo.clear();
    try{
      await ref.child('Contact').child(myPhoneNumber).once().then((DataSnapshot snap) {
        var keys = snap.value.keys;
        var data = snap.value;
        for (var key in keys) {
          DBContacts d = new DBContacts(key, data[key]['name'], data[key]['phoneNumber'],);
          liContactUserInfo.add(d); 
        }
      });
       setState(() {
          print('length : ${liContactUserInfo.length}');
      });
      
    }
    catch(Exception){
       print('error');
    }
  }

  @override
  void initState() {
    myPhoneNumber =
        Provider.of<UserInfomation>(context, listen: false).details.phoneNumber;
    lock.synchronized(getDBData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _navigateAndDisplaySelection(context);
          setState(() {
            lock.synchronized(getDBData);
          });
          
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: Icon(Icons.plus_one),
      ),
      body: Container(
        child: liContactUserInfo != null ? ListView.builder(
          itemCount: liContactUserInfo.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            DBContacts dbContacts = liContactUserInfo.elementAt(index);
            return ListTile(
              onTap: () {
                createAlertDialog(context, index);
              },
              leading: (dbContacts.name != null && dbContacts.name.length > 0)
                  ? CircleAvatar(child: Text(dbContacts.name.substring(0,1)), backgroundColor: Colors.black, foregroundColor: Colors.white,)
                  : CircleAvatar(child: Text('-'), backgroundColor: Colors.black, foregroundColor: Colors.white,),
              title: Text(dbContacts.name ?? ""),
              subtitle: Text(dbContacts.phoneNumber ?? ""),
            );
          },
        )
        : Center(child: CircularProgressIndicator(),),
      ),
    );
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    try{
      int pageNumber = 2;
      contactUserInfo = await Navigator.push(context, MaterialPageRoute(builder: (context) => GetContactPage(selectedIndex: pageNumber,)));
      if(contactUserInfo.phoneNumber != null){
        contactUserInfo.phoneNumber = (contactUserInfo.phoneNumber as String).replaceAll('-', '');
      }

      await checkOverlap();
    }
    catch(Exception){
      print('get Contact Error');
    }

    
  } 

  Future checkOverlap() async{
    
    bool isRegisted = false;
    for(DBContacts dbContact in  liContactUserInfo){
      if(dbContact.phoneNumber == contactUserInfo.phoneNumber){
        isRegisted = true;
        SnackBar alertSnackbar = SnackBar(
            content: Text('전화번호가 등록되어 있습니다.'),
        );
        Scaffold.of(context).showSnackBar(alertSnackbar);
        break;
      }
    }
    if(isRegisted == false){
      await createDatabase();
    }
    
    return;
  }

  createAlertDialog(BuildContext context, int index) async {
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
                color: Colors.blue,
                child: Text('친구 삭제하기'),
                onPressed: () {
                  deleteFriend(context, index);
                  
                },
              ),
            ),
          ],
        );
      }
    );
  }

  deleteFriend(BuildContext context, int index) async{
    await deleteDatabase(index);
    Navigator.of(context).pop(true);

  }
}