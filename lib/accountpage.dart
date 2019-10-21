import 'package:flutter/material.dart';
import 'package:jtbcontract/data/userinfo.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
          child : Center(
                  child: 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage:NetworkImage(Provider.of<UserInfomation>(context).details.photoUrl),
                          radius: 50.0,
                        ),
                        SizedBox(height:10.0),
                          Text(
                          "Name : " + Provider.of<UserInfomation>(context).details.userName,
                          style:  TextStyle(fontWeight: FontWeight.bold, color: Colors.black,fontSize: 20.0),
                        ),
                        SizedBox(height:10.0),
                          Text(
                          "Email : " + Provider.of<UserInfomation>(context).details.userEmail,
                          style:  TextStyle(fontWeight: FontWeight.bold, color: Colors.black,fontSize: 20.0),
                        ),
                        SizedBox(height:10.0),
                        Text(
                          "Provider : " + Provider.of<UserInfomation>(context).details.providerDetails,
                          style:  TextStyle(fontWeight: FontWeight.bold, color: Colors.black,fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),
        );
   
  }
}