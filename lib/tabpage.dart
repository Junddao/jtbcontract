import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jtbcontract/accountpage.dart';
import 'package:jtbcontract/friendpage.dart';
import 'package:jtbcontract/searchPage.dart';
import 'package:jtbcontract/writepage2.dart';
import 'package:provider/provider.dart';
import 'data/tabstates.dart';

class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  final List<Widget> _tabs = [
    //WritePage(),
    WritePage2(),
    SearchPage(),
    FreindPage(),
    AccountPage(),
  ];

  @override
  void initState() {
    
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();

    return Consumer<TabStates>(
        builder: (context, value, child) => Scaffold(
            appBar: AppBar(
              // title:  Text(snapshot.data.userName),
              title: getTitleText(),

              backgroundColor: Colors.white10,
              bottomOpacity: 0.0,
              elevation: 0.0,
              automaticallyImplyLeading: false,
              // actions: <Widget>[
              //   IconButton(
              //     icon: Icon(
              //       FontAwesomeIcons.signOutAlt,
              //       size: 20.0,
              //       color: Colors.white,
              //     ),
              //     onPressed: () {
              //       _gSignIn.signOut();
              //       print('Signed out');
              //       Navigator.pop(context);
              //     },
              //   ),
              // ],
            ),
            body: _tabs[Provider.of<TabStates>(context).selectedIndex],
            bottomNavigationBar: new Theme(
                data: Theme.of(context).copyWith(
                    // sets the background color of the `BottomNavigationBar`
                    canvasColor: Colors.white,
                    // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                    primaryColor: Colors.red,
                    textTheme: Theme.of(context).textTheme.copyWith(
                        caption: new TextStyle(
                            color: Colors
                                .grey))), // sets the inactive color of the `BottomNavigationBar`

                child: new BottomNavigationBar(
                    onTap: _onItemTapped,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: value.selectedIndex,
                    items: <BottomNavigationBarItem>[
                      // BottomNavigationBarItem(
                      //     icon: Icon(Icons.mic),
                      //     title: Text('녹음')), // 뭘 보여줘야 할까...
                      BottomNavigationBarItem(
                          icon: Icon(Icons.create),
                          title: Text('쓰기')), // 
                      BottomNavigationBarItem(
                          icon: Icon(Icons.search),
                          title: Text('찾기')), // 계약서 작성 페이지
                      BottomNavigationBarItem(
                          icon: Icon(Icons.group),
                          title: Text('친구')), // 내 계정 확인, 작성 문서찾기
                      BottomNavigationBarItem(
                          icon: Icon(Icons.supervised_user_circle),
                          title: Text('내계정')), // 내 계정 확인, 작성 문서찾기
                    ]))));
  }

  Text getTitleText(){
    String titleText;
    
    // if(Provider.of<TabStates>(context).selectedIndex == 0) titleText = '녹음';
    if(Provider.of<TabStates>(context).selectedIndex == 0) titleText = '쓰기';
    if(Provider.of<TabStates>(context).selectedIndex == 1) titleText = '찾기';
    if(Provider.of<TabStates>(context).selectedIndex == 2) titleText = '친구';
    if(Provider.of<TabStates>(context).selectedIndex == 3) titleText = '내계정';
    
    return Text(
      titleText,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  void _onItemTapped(int value) {
    Provider.of<TabStates>(context).selectedIndex = value;
  }
}
