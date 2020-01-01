import 'package:contacts_service/contacts_service.dart';

class ContactUserInfo{
  var _phoneNumber;

  get phoneNumber => _phoneNumber;

  set phoneNumber(phoneNumber) {
    _phoneNumber = phoneNumber;
  }
  String _name;

  String get name => _name;

  set name(String name) {
    _name = name;
  }

  ContactUserInfo();
}