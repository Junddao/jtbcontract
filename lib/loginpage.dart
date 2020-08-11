import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jtbcontract/data/userinfo.dart';
import 'package:jtbcontract/tabpage.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String mobileNumber;

  GoogleSignIn _googleSignIn = new GoogleSignIn();

// scopes: <String>[
//       'email',
//       '',
//     ],
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  bool isLogin = false;

  Future<void> testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser userDetails =
        (await _auth.signInWithCredential(credential)).user;

    mobileNumber = await MobileNumber.mobileNumber;
    if(mobileNumber.substring(0, 1) == '+') mobileNumber = mobileNumber.substring(1);
    if(mobileNumber.substring(0, 2) == '82') mobileNumber = mobileNumber.substring(2);
    if(mobileNumber.substring(0, 1) == '1') mobileNumber = '0' + mobileNumber;

    UserInfoDetails details = new UserInfoDetails(
      userDetails.providerId,
      userDetails.displayName,
      userDetails.photoUrl,
      userDetails.email,
      mobileNumber,
    );

    Provider. of<UserInfomation>(context).details = details;
    Navigator.of(context)
            .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => TabPage()),(Route<dynamic> route) => false);

  }


  @override
  void initState() {
   
    super.initState();
    
  }


  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Builder(
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,

              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage('images/loginImage.jpg'),
                ),
              ),
              // child: Image.network(
              //     'https://cdn.pixabay.com/photo/2014/11/20/13/54/blueberry-539134_960_720.jpg',
              //     fit: BoxFit.fill,
              //     color: Color.fromRGBO(255, 255, 255, 0.6),
              //     colorBlendMode: BlendMode.modulate),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(height: 10.0),
                Container(
                  width: 250.0,
                  child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Color(0xffffffff),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.google,
                              color: Color(0xffCE107C),
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 18.0),
                            ),
                          ],
                        ),
                        onPressed: testSignInWithGoogle,
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
