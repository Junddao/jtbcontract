class DBData{
  dynamic key;
  String sender, receiver, savedPath, status, contents;
  bool isSelected = false;

  DBData(this.key, this.sender, this.receiver, this.savedPath, this.status, this.contents);
}