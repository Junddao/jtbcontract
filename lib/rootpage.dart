import 'package:firebase_auth/firebase_auth.dart';
import 'package:flt_telephony_info/flt_telephony_info.dart';
import 'package:flutter/material.dart';
import 'package:jtbcontract/data/userinfo.dart';
import 'package:jtbcontract/loginpage.dart';
import 'package:jtbcontract/service/checkGoogleLoginOrNot.dart';
import 'package:jtbcontract/tabpage.dart';
import 'package:provider/provider.dart';


class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginPage() ,
    );
  }
}
