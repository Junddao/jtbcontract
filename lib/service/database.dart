import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';

class Database{
  static Future<void> createData(String _appAdminPhoneNumber, String _senderPhoneNumber, String _receiverPhoneNumber, String _savedPath, String _fileName, String _approvalCondition) async{
    FirebaseDatabase.instance.reference().push()
        .child(_appAdminPhoneNumber).push()
        .set({
      'sender': _senderPhoneNumber,
      'receiver': _receiverPhoneNumber,
      'savedPath': _savedPath,
      'status': _approvalCondition,
      'content': '',
    });
  }
  
}