import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtbcontract/accountpage.dart';
import 'package:jtbcontract/searchPage.dart';
import 'package:provider/provider.dart';
import 'data/tabstates.dart';

class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  final List<Widget> _tabs = [SearchPage(), AccountPage()];
  
  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();

    return Consumer<TabStates>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          // title:  Text(snapshot.data.userName),
          title: Text("test"),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                FontAwesomeIcons.signOutAlt,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: () {
                _gSignIn.signOut();
                print('Signed out');
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: _tabs[Provider.of<TabStates>(context).selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
            onTap: _onItemTapped,
            currentIndex: value.selectedIndex,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text('Home')), // 뭘 보여줘야 할까...
              BottomNavigationBarItem(
                  icon: Icon(Icons.border_color),
                  title: Text('Write')), // 계약서 작성 페이지
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  title: Text('Account')), // 내 계정 확인, 작성 문서찾기
            ])),
      );
  }

  void _onItemTapped(int value) {
    Provider.of<TabStates>(context).selectedIndex = value;
  }
}
