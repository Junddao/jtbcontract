import 'package:flutter/material.dart';
import 'package:jtbcontract/data/contactUserInfo.dart';
import 'package:jtbcontract/getContactsPage.dart';

class FreindPage extends StatefulWidget {
  @override
  _FreindPageState createState() => _FreindPageState();
}

class _FreindPageState extends State<FreindPage> {

  ContactUserInfo contactUserInfo = new ContactUserInfo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _navigateAndDisplaySelection(context);
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: Icon(Icons.plus_one),
      ),
      body: Container(
        child: Text('aaa'),
      ),
    );
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // phoneNumber = await Navigator.pushNamed(context, GetContactRoute);
    contactUserInfo = await Navigator.push(context, MaterialPageRoute(builder: (context) => GetContactPage()));
    if(contactUserInfo.phoneNumber != null){
      contactUserInfo.phoneNumber = (contactUserInfo.phoneNumber as String).replaceAll('-', '');
    }
  } 
}