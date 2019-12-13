import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class InputPhoneNumber extends StatefulWidget {
  @override
  _InputPhoneNumberState createState() => _InputPhoneNumberState();
}

class _InputPhoneNumberState extends State<InputPhoneNumber> {

  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Container(
          padding: const EdgeInsets.all(40.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 10,
                child: TextField(
                  controller: myController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'phone Number',
                  ),
                ),
              ),
              
              Expanded(
                flex: 1,
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
                      icon: Icon(Icons.send), //`Icon` to display
                      label: Text('Send'), //`Text` to display
                      onPressed: () {
                        Navigator.pop(context, myController.text);
                      },
                    ),),
                  ],
                )
              )

              
              

              // new TextField(
              //   decoration: new InputDecoration(labelText: "Enter your number"),
              //   keyboardType: TextInputType.number,
              //   inputFormatters: <TextInputFormatter>[
              //     WhitelistingTextInputFormatter.digitsOnly
              //   ], // Only numbers can be entered
              // ),
            ],
          )),
    );
  }
}
