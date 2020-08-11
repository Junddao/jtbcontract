import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jtbcontract/data/tabstates.dart';
import 'package:jtbcontract/data/userinfo.dart';
import 'package:jtbcontract/rootpage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(new MaterialApp(
    home: MyApp(),
    //onGenerateRoute: generateRoute,
    //initialRoute: RootPageRoute,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String textValue = 'Hello World';
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print('onlaunch');
    }, onResume: (Map<String, dynamic> msg) {
      print('onResume');
    }, onMessage: (Map<String, dynamic> msg) {
      print('onMessage');
    });
    firebaseMessaging
        .requestNotificationPermissions(const IosNotificationSettings(
      sound: true,
      alert: true,
      badge: true,
    ));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS setting');
    });
    firebaseMessaging.getToken().then((token) {
      update(token);
    });
    super.initState();
  }

  update(String token) {
    print(token);

    textValue = token;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 3,
      navigateAfterSeconds: new AfterSplash(),
      title: new Text(
        'J T B',
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
          color: Colors.black,
        ),
      ),
      //image: new Image.network('https://i.imgur.com/TyCSG9A.png'),

      backgroundColor: Colors.white,
      // styleTextUnderTheLoader: new TextStyle(
      //   fontSize: 12.0,
      //   fontWeight: FontWeight.bold,
      //   color: Colors.white
      // ),
      photoSize: 100.0,
      loaderColor: Colors.white,
      //loadingText: Text('Now Loading'),
    );
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    permission();
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserInfomation>(
            builder: (context) => UserInfomation(),
          ),
          ChangeNotifierProvider<TabStates>(
            builder: (context) => TabStates(),
          ),
        ],
        child: MaterialApp(
          home: RootPage(),
        ));
  }

  void permission() async {
    //await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
    //await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
    await PermissionHandler().requestPermissions([PermissionGroup.phone]);
    //await PermissionHandler().requestPermissions([PermissionGroup.sms]);
  }
}
