
import 'package:flutter/material.dart';

class UserInfomation with ChangeNotifier{

  UserInfoDetails _details;

  UserInfoDetails get details => _details;
  set details(UserInfoDetails details) {
    _details = details;
    notifyListeners();
  }

}

class UserInfoDetails{
  final String providerDetails;
  final String userName;
  final String photoUrl;
  final String userEmail;
  final String phoneNumber;

  
  UserInfoDetails(this.providerDetails, this.userName, this.photoUrl, this.userEmail, this.phoneNumber);
}


