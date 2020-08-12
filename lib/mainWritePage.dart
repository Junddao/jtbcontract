import 'package:flutter/material.dart';
import 'package:jtbcontract/writepage.dart';
import 'package:jtbcontract/writepage2.dart';

class MainWritePage extends StatefulWidget {
  @override
  _MainWritePageState createState() => _MainWritePageState();
}

class _MainWritePageState extends State<MainWritePage>
    with SingleTickerProviderStateMixin {
  TabController ctr;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    ctr = new TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: new TabBar(
            indicatorColor: Colors.pink,
            labelColor: Colors.black,
            controller: ctr,
            tabs: <Tab>[
              new Tab(
                icon: Icon(Icons.assignment),
                text: '글로 쓰는 약속',
              ),
              new Tab(
                icon: Icon(Icons.keyboard_voice),
                text: '말로 하는 약속',
              ),
            ],
          ),
        ),
      ),
      body: Container(
        child: TabBarView(
          controller: ctr,
          children: <Widget>[
            WritePage2(),
            WritePage(),
          ],
        ),
      ),
    );
  }
}
