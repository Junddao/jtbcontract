import 'package:contacts_service/contacts_service.dart';

class MyContactsService{

  List<Contact> contacts;
  String selectedPhoneNumber;

  MyContactsService(){
    refreshContacts();
  }

  
  void refreshContacts() async{
    //PermissionStatus permissionStatus = await _getContactPermission();
    //if (permissionStatus == PermissionStatus.granted) {
      // Load without thumbnails initially.
    contacts = (await ContactsService.getContacts(withThumbnails: false)).toList();

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        contact.avatar = avatar;
      });
    }
  }
  
  getPhoneNumber(Contact _c) async{
    List<String> liPhoneNumber = _c.phones.map((i) => i.value).toList();
    for(String s in liPhoneNumber){
      if(s.substring(0, 3).contains('010') 
        || s.substring(0, 3).contains('011')
        || s.substring(0, 3).contains('016')
        || s.substring(0, 3).contains('017')
        || s.substring(0, 3).contains('019'))
      {
        selectedPhoneNumber = s;
        return;
      }
    }
  }
  
}