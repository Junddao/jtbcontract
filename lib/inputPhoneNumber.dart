import 'package:flutter/material.dart';
import 'package:jtbcontract/data/contactUserInfo.dart';

  @override
class InputPhoneNumber extends StatefulWidget {
  _InputPhoneNumberState createState() => _InputPhoneNumberState();
}

class _InputPhoneNumberState extends State<InputPhoneNumber> {

  final myPhoneNumberController = TextEditingController();
  final myNameController = TextEditingController();

  @override
  void dispose() {
    myPhoneNumberController.dispose();
    myNameController.dispose();
    super.dispose();
  }

  ContactUserInfo contactUserInfo = new ContactUserInfo();

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Container(
        padding: const EdgeInsets.all(40.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            
            SizedBox(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: myPhoneNumberController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '전화번호',
                  ),
                ),
              ), 
            ),
            Expanded(
              child: new Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: FlatButton.icon(
                      color: Colors.white,
                      icon: Icon(Icons.cancel), //`Icon` to display
                      label: Text('취소'), //`Text` to display
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                    ),),
                    Expanded(
                      flex: 1,
                      child: FlatButton.icon(
                      color: Colors.white,
                      icon: Icon(Icons.send), //`Icon` to display
                      label: Text('보내기'), //`Text` to display
                      onPressed: () {
                        getPhoneNumber();
                        getPhoneName();
                        Navigator.pop(context, contactUserInfo);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),],
        ),
      ),
    );
  }

  getPhoneNumber() {
    contactUserInfo.phoneNumber = myPhoneNumberController.text;
  }

  getPhoneName() {
    contactUserInfo.name = myNameController.text;
  }
}
