class DBData{
  dynamic key;
  String date, senderPhoneNumber, senderName, receiverPhoneNumber, receiverName, savedPath, status, contents;
  bool isSelected = false;

  DBData(this.key, this.date, this.senderPhoneNumber, this.senderName, this.receiverPhoneNumber, this.receiverName, this.savedPath, this.status, this.contents);
}

class DBContacts{
  dynamic key;
  String name, phoneNumber;
  bool isSelected = false;

  DBContacts(this.key, this.name, this.phoneNumber);
}