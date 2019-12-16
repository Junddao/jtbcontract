import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtbcontract/getContactsPage.dart';
import 'package:jtbcontract/inputPhoneNumber.dart';
import 'package:jtbcontract/loginpage.dart';
import 'package:jtbcontract/rootpage.dart';
import 'package:jtbcontract/service/routingConstants.dart';
import 'package:jtbcontract/tabpage.dart';
import 'package:jtbcontract/writepage.dart';

class Router{
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
    case RootPageRoute :
      return MaterialPageRoute(builder: (context) => RootPage());
    case WritePageRoute :
      return MaterialPageRoute(builder: (context) => WritePage());
    case GetContactRoute :
      return MaterialPageRoute(builder: (context) => GetContactPage());
    case InputPhoneNumberRoute :
      return MaterialPageRoute(builder: (context) => InputPhoneNumber());
    case TabPageRoute :
      return MaterialPageRoute(builder: (context) => TabPage());
    case LoginPageRoute :
      return MaterialPageRoute(builder: (context) => LoginPage());
    default:
      return MaterialPageRoute(builder: (context) => TabPage());
    }
  }
}

  