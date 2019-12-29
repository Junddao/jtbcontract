import 'package:flutter/material.dart';
import 'package:jtbcontract/data/contactUserInfo.dart';

class SaveFriend extends StatefulWidget {
  @override
  _SaveFriendState createState() => _SaveFriendState();
}

class _SaveFriendState extends State<SaveFriend> {

  final myPhoneNumberController = TextEditingController();
  final myNameController = TextEditingController();
  bool isCheckNumber = false;

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
                  controller: myNameController,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 3.0)),
                    border: OutlineInputBorder(),
                    labelText: '등록할 이름',
                  ),
                ),
              ), 
            ),
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
                      label: Text('cancel'), //`Text` to display
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                    ),),
                    Expanded(
                      flex: 1,
                      child: FlatButton.icon(
                      color: Colors.white,
                      icon: Icon(Icons.add), //`Icon` to display
                      label: Text('Add'), //`Text` to display
                      onPressed: () {
                        checkPhoneNumber();
                        if(isCheckNumber == true){
                          getPhoneNumber();
                          getPhoneName();
                          Navigator.pop(context, contactUserInfo);
                        }
                        else{
                          SnackBar alertSnackbar = SnackBar(
                            content: Text('번호를 잘못 입력하셨습니다.'),
                          );
                          Scaffold.of(context).showSnackBar(alertSnackbar);
                        }
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

  checkPhoneNumber(){
    String _checkNumber = myPhoneNumberController.text.substring(0, 3);
    if(_checkNumber.contains('010')  ||
    _checkNumber.contains('011') ||
    _checkNumber.contains('016') ||
    _checkNumber.contains('017') ||
    _checkNumber.contains('019')) {
      isCheckNumber = true;
    }
    else{
      isCheckNumber = false;
      
    }

  }

  getPhoneNumber() {
    
    contactUserInfo.phoneNumber = myPhoneNumberController.text;
  }

  getPhoneName() {
    contactUserInfo.name = myNameController.text;
  }
}
